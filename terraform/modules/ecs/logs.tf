module "log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"

  name              = "${var.prefix}-polytomic-logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-polytomic-logs"
    }
  )
}


module "ecs_log_groups" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"

  for_each = toset(["sync", "scheduler", "schemacache", "stats-reporter", "web", "worker", "ingest"])

  name              = "${var.prefix}-${each.key}-logs"
  retention_in_days = var.log_retention_days


  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-${each.key}-logs"
    }
  )
}
