module "log_group" {
  source = "terraform-aws-modules/cloudwatch/aws//modules/log-group"

  name              = "${var.prefix}-polytomic-logs"
  retention_in_days = var.log_retention_days

  tags = var.tags
}
