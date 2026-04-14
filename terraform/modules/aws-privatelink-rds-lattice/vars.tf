variable "name" {
  description = "Name prefix applied to the resource gateway, resource configuration, and RAM share."
  type        = string
  default     = "polytomic-privatelink"
}

variable "vpc_id" {
  description = "VPC hosting the existing RDS instance. The Resource Gateway is created in this VPC."
  type        = string
}

variable "subnet_ids" {
  description = <<-EOT
    Private subnet IDs in which the VPC Lattice Resource Gateway is placed.
    These subnets must be able to route to the RDS instance. Provide at least
    two across distinct AZs for high availability.
  EOT
  type        = list(string)
}

variable "rds_host" {
  description = <<-EOT
    The RDS instance hostname (the `address` attribute of `aws_db_instance`).
    Unlike the NLB variant, this is passed through to a `dns_resource` on the
    resource configuration — Lattice re-resolves it, so RDS failover is
    handled automatically.
  EOT
  type        = string
}

variable "rds_port" {
  description = "Postgres port on the RDS instance."
  type        = number
  default     = 5432
}

variable "rds_security_group_id" {
  description = <<-EOT
    The security group attached to the RDS instance. A rule is added allowing
    inbound traffic on `rds_port` from the resource gateway's security group.

    This is the step most manually-configured Lattice setups miss. Without it,
    connections reach the resource gateway but hang trying to reach RDS.
  EOT
  type        = string
}

variable "polytomic_aws_account_id" {
  description = <<-EOT
    The AWS account ID Polytomic will use to create the consumer-side VPC
    endpoint. Polytomic will provide this — ask your Solutions Engineer if you
    don't have it. This account is added as a RAM principal on the resource
    share.
  EOT
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
