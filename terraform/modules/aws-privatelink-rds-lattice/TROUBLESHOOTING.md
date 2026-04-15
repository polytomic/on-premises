# Troubleshooting: Lattice RDS connection timing out

This guide walks through the most common reasons a Polytomic connection to
an RDS instance exposed via the `aws-privatelink-rds-lattice` module fails
with a connection timeout.

A timeout (as opposed to an auth error or a DNS NXDOMAIN) almost always
means one of the network hops is silently dropping traffic. Work through the
layers below in order — the goal is to find the first hop where traffic
doesn't arrive.

## The path traffic takes

```
Polytomic app
  → VPC endpoint (Resource type) in the Polytomic consumer VPC
  → VPC Lattice service network / data plane  (cross-account, cross-region)
  → Resource gateway ENI in your VPC
  → RDS instance
```

Anything upstream of the resource gateway is Polytomic's responsibility —
skip to the "Producer-side checks" section first, since that's the portion
you control, and it's where the vast majority of real-world failures live.

## 0. Pre-flight — what we need from you

Please have these ready before digging in:

- The **resource configuration ARN** (output of the module as
  `resource_configuration_arn`).
- The **resource gateway ID** (module output `resource_gateway_id`).
- The **RDS instance identifier** and the endpoint hostname you passed to
  the module as `rds_host`.
- The **VPC ID** the resource gateway is in, and the **subnet IDs** it was
  given.
- The **security group ID** on the RDS instance.
- Confirmation that you accepted the RAM share in your account (not the
  point — you're the producer — but worth confirming it's not accidentally
  double-shared or mis-targeted).

## 1. Resource configuration health

In the AWS Console, in the region where your RDS lives:

**VPC → PrivateLink and Lattice → Resource configurations → [your config]**

Check:

- **Status** should be `Active`. Anything else (`Create in progress`,
  `Create failed`) means traffic cannot be reaching the data plane yet.
- The **resource gateway** should be listed as `Active` too (same screen,
  click through to the gateway).
- **Resource gateway IP addresses** should be populated — one ENI per
  subnet you passed as `subnet_ids`.

If the resource configuration or gateway is not `Active`, re-apply the
module and share the `tofu apply` output with us. Don't proceed until both
are healthy.

## 2. Producer-side reachability — can the resource gateway actually reach RDS?

This is the #1 cause of silent timeouts. The resource gateway has ENIs in
the subnets you passed; those ENIs need to be able to open TCP to the RDS
instance on the Postgres port. Test this directly, **bypassing Lattice
entirely**.

You have two options — we recommend trying **VPC Reachability Analyzer
first** (§2a); it's faster and produces a machine-readable verdict. If for
some reason RA won't cooperate, fall back to the EC2 approach in §2b.

### 2a. VPC Reachability Analyzer (preferred)

Reachability Analyzer is an AWS tool that simulates a packet from a source
ENI to a destination and tells you either "reachable" or exactly which
hop (SG, NACL, route table) drops it. Because the resource gateway ENIs
and the RDS ENIs are in the same VPC and same account, this is a clean
use case.

1. Find the **resource gateway ENIs**: EC2 Console → Network Interfaces,
   filter by description containing the resource gateway ID (module
   output `resource_gateway_id`, looks like `rgw-xxxxxxxx`). There's one
   ENI per subnet you passed as `subnet_ids`.
2. Find an **RDS ENI**: EC2 Console → Network Interfaces, filter by
   description containing the RDS instance identifier, or by the RDS
   security group. Any one of the RDS ENIs is fine.

   > **Aurora note:** Aurora cluster endpoints are DNS names that
   > resolve to a current instance's IP and change on failover —
   > Reachability Analyzer can only target a specific ENI, not a DNS
   > name. Pick any one Aurora instance's ENI; all instances in the
   > cluster share a subnet group and security group, so if one is
   > reachable, they all are. (At runtime, Lattice re-resolves the
   > cluster endpoint you passed to the module on every new connection,
   > so failover is still handled transparently — RA is only checking
   > the underlying network path.)
3. Go to **VPC → Reachability Analyzer → Create and analyze path**:
   - **Source type**: Network interface → select a resource gateway ENI.
   - **Destination type**: Network interface → select the RDS ENI.
   - **Protocol**: TCP
   - **Destination port**: 5432 (or whatever you passed as `rds_port`)
   - Leave source port empty.
4. Run the analysis. It takes ~30 seconds.

**Reachable**: producer side is fine. Skip to §3.

**Not reachable**: the result will name the exact component that drops
the packet — usually a security group or NACL. Common findings:

- *"The security group ... does not have a rule that allows ..."* on the
  RDS SG → the module's ingress rule is missing or was removed. Re-apply
  the module, or confirm you passed the right `rds_security_group_id`.
- *"The security group ... does not have a rule that allows ..."* on the
  gateway SG's egress → something has modified the SG the module created.
- *"No route in route table ..."* → the gateway subnets and the RDS
  subnets are in different VPCs, or a custom route table is missing the
  local route.
- A NACL entry denying the traffic → remove or adjust the NACL rule.

Fix whatever RA flags, re-run the analysis until it's `Reachable`, then
ask Polytomic to retry the connection.

### 2b. Fallback: launch a throwaway EC2 instance in one of the gateway subnets

Pick one of the subnets you passed to the module as `subnet_ids`, and
launch a t3.micro Amazon Linux 2023 instance there. Attach the **resource
gateway's security group** to it (not the default SG) — that way the test
instance sees exactly the same network policy the gateway sees.

The gateway's SG is the one created by the module, named `<name>-rg`
(e.g. `granola-main-db-rg`).

Connect via SSM Session Manager (no SSH key or public IP needed).

### 2c. Resolve the RDS hostname from the instance

```bash
dig +short <rds-host>
```

You should get a **private** IP (typically in the VPC CIDR range). If you
get a public IP instead, your RDS instance is marked publicly accessible
*and* the DNS lookup is happening from outside AWS's DNS split-horizon —
something is wrong with VPC DNS settings. Check:

- `enable_dns_support = true` on the VPC
- `enable_dns_hostnames = true` on the VPC
- The instance is using the VPC's default resolver (169.254.169.253), not
  an external one.

### 2d. Open a TCP connection to RDS directly

```bash
nc -vz <rds-host> 5432
```

Expected output: `Connection to ... 5432 port [tcp/postgresql] succeeded!`

**If this hangs or says "Connection timed out":** the problem is entirely
inside your VPC and has nothing to do with Lattice yet. Work down this
list:

1. **RDS security group ingress rule.** The module adds a rule allowing
   inbound from the gateway's SG. Confirm it's still there:
   AWS Console → RDS → [your DB] → Connectivity & security → VPC security
   groups → inbound rules. You should see a rule allowing TCP on the
   Postgres port from source = `<name>-rg` SG.
2. **Multiple security groups on RDS.** If RDS has more than one SG
   attached, the module only adds a rule to the one you passed as
   `rds_security_group_id`. Make sure you passed the SG that is actually
   attached to the instance — not a leftover one.
3. **Different VPC.** Double-check RDS is in the *same VPC* you passed as
   `vpc_id`. The resource gateway can only reach RDS if they share a VPC
   (or that VPC is peered and routed, which gets painful — please don't).
4. **Network ACLs.** Default NACLs are fully open, but if you have custom
   NACLs on the gateway subnets or the RDS subnets, they need to allow
   ephemeral-port return traffic. Look for NACLs with `Deny` rules.
5. **Route tables.** Confirm the route tables on the gateway subnets have
   a local route for the VPC CIDR (they always do unless something weird
   was done — worth glancing at).
6. **RDS in a private subnet with no route back.** Rare, but if RDS was
   placed in a subnet whose route table was customized, return traffic
   might vanish. Check route table for the RDS subnet too.

**If `nc` succeeds:** producer side is fine. Skip to §3.

### 2e. Also try connecting to Postgres

```bash
psql "host=<rds-host> port=5432 user=<user> dbname=<db>"
```

This proves the DB is actually accepting connections (not just the TCP
socket). If `nc` succeeded but `psql` hangs or rejects you, the issue is
DB-level (pg_hba, max_connections, auth) — let us know.

## 3. Resource gateway observability

Once you've confirmed direct producer-side connectivity works, check that
the resource gateway itself is passing traffic:

**VPC → PrivateLink and Lattice → Resource gateways → [your gateway] →
Monitoring**

Look at:

- `BytesProcessed` / `NewConnectionCount` — should be nonzero once
  Polytomic attempts a connection. If zero, no traffic is reaching the
  gateway at all (likely a consumer-side or data-plane issue — tell us).
- `ConnectionErrors` — nonzero here points at the gateway failing to
  complete connections (usually to RDS). If you see this *after* §2
  passed, there is something intermittent — capture a timestamp and send
  it to us.

You can also enable VPC Flow Logs on the gateway's ENIs for a short window
and filter for traffic on the Postgres port — that gives you a
packet-level view of whether traffic is arriving and whether return
packets are leaving.

