module "log_group" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 3.0"

  name              = "${var.prefix}-polytomic-logs"
  retention_in_days = 120

  tags = var.tags
}
