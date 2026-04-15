variable "name" {
  description = "Name prefix applied to the NLB, target group, and endpoint service."
  type        = string
  default     = "polytomic-privatelink"
}

variable "vpc_id" {
  description = "VPC hosting the existing RDS instance. The NLB is created in this VPC."
  type        = string
}

variable "subnet_ids" {
  description = <<-EOT
    Private subnet IDs in which to place the NLB. Provide at least two across
    distinct AZs for high availability. These must be able to route to the
    RDS instance's IP.
  EOT
  type        = list(string)
}

variable "rds_host" {
  description = <<-EOT
    The RDS instance hostname (the `address` attribute of `aws_db_instance`,
    e.g. `mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com`). Resolved once at
    apply time to an IP that is registered as an NLB target.

    IMPORTANT: NLBs only support IP targets, not DNS. If RDS fails over to a
    different IP, connections via PrivateLink will break until this module is
    re-applied. If you are running RDS Multi-AZ and need failover tolerance,
    use the `aws-privatelink-rds-lattice` module instead.
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
    inbound traffic from the VPC CIDR on `rds_port` so the NLB's IP targets
    can reach RDS.
  EOT
  type        = string
}

variable "polytomic_aws_account_id" {
  description = <<-EOT
    The AWS account ID Polytomic will use to create the consumer-side VPC
    endpoint. Polytomic will provide this — ask your Solutions Engineer if you
    don't have it. This account is added to the VPC Endpoint Service's
    `allowed_principals`.
  EOT
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources created by this module."
  type        = map(string)
  default     = {}
}
