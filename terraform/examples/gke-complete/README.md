# Polytomic on GKE — Complete Example

This example deploys Polytomic on Google Kubernetes Engine using two
Terraform configurations applied in sequence:

1. **cluster/** — GKE cluster, Cloud SQL (PostgreSQL), Memorystore
   (Redis), GCS bucket, networking, and IAM.
2. **app/** — Helm release of Polytomic into the cluster, plus a
   Google-managed SSL certificate and DNS record.

## Prerequisites

- A GCP project with the following APIs enabled:
  - Kubernetes Engine, Cloud SQL Admin, Cloud Memorystore for Redis,
    Compute Engine, Cloud Resource Manager
- Terraform (or OpenTofu) >= 1.3
- `gcloud` CLI authenticated with permissions to manage the above
  resources
- Access to the Polytomic container registry
  (`us.gcr.io/polytomic-container-distro`)

## Cluster Install

```sh
cd cluster
terraform init
terraform apply
```

Note the outputs — `load_balancer_ip` and `workload_identity_user_sa`
are needed for DNS and registry access respectively.

After applying:

1. Create a DNS A record pointing your chosen domain to the
   `load_balancer_ip` output.
2. Send the `workload_identity_user_sa` output to Polytomic
   (support@polytomic.com or via Slack) so we can grant it pull access
   to the Polytomic container registry. The app install will fail until
   this is complete.

## App Install

Edit `app/main.tf` to set your deployment details (domain, deployment
key, OAuth credentials, image tag), then:

```sh
cd app
terraform init
terraform apply
```

## TLS

### Google-Managed Certificates

This example creates a Google-managed certificate for TLS termination.
Provisioning usually takes 10–15 minutes but can take up to 60 minutes.
The certificate will not provision until the DNS A record is in place
and resolves to the load balancer IP.

### Bring Your Own Certificates

Import your own certificate into GCP:

```sh
gcloud compute ssl-certificates create my-polytomic-cert \
  --certificate my-cert.pem \
  --private-key my-key.key
```

Then update the `polytomic_cert_name` parameter in the app module to
reference the imported certificate.

## Managed Logging (Datadog)

To forward logs to Polytomic-managed Datadog, enable managed logs in the
app module:

```hcl
polytomic_managed_logs = true
```

This requires a deployment key provisioned for managed logging. The
Vector DaemonSet (enabled by default) collects logs from all Polytomic
pods and forwards them to Datadog. Execution logs are also written to
the GCS bucket.

To also enable APM tracing via the Datadog Agent DaemonSet:

```hcl
polytomic_use_dd_agent = true
```

Both DaemonSets authenticate to GCS via Workload Identity using the
same service account as the main Polytomic pods. To use a dedicated
service account for the Vector DaemonSet, set
`logger_workload_identity_sa` in the cluster module and
`polytomic_logger_service_account` in the app module.

## Workload Identity

The cluster module creates a GCP service account with
`roles/iam.workloadIdentityUser` bindings for both the `polytomic` and
`polytomic-vector` Kubernetes service accounts in the `polytomic`
namespace. This allows pods to authenticate to GCS and other GCP
services without static credentials.
