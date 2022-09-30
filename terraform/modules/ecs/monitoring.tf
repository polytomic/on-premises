resource "aws_kms_key" "alerts" {}

resource "aws_sns_topic" "alerts" {
  name              = "${var.prefix}-alerts"
  kms_master_key_id = aws_kms_key.alerts.arn
}

resource "aws_sns_topic_subscription" "alert_emails" {
  for_each  = toset(var.alert_emails)
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = each.key
}


module "rds-alerts" {
  source = "../monitoring/rds-alerts"
  count  = var.database_endpoint == "" && var.enable_monitoring ? 1 : 0

  name           = format("%s-database", var.prefix)
  db_instance_id = module.database[0].db_instance_id
  sns_topic_arns = [aws_sns_topic.alerts.arn]

}

module "elasticache-alerts" {
  source = "../monitoring/elasticache-alerts"
  count  = var.redis_endpoint == "" && var.enable_monitoring ? 1 : 0

  name             = format("%s-elasticache", var.prefix)
  cache_cluster_id = module.redis[0].elasticache_replication_group_member_clusters
  sns_topic_arns   = [aws_sns_topic.alerts.arn]

}

module "ecs-alerts-worker" {
  for_each = var.ecs_cluster_name == "" && var.enable_monitoring ? toset(
    [
      aws_ecs_service.web.name,
      aws_ecs_service.worker.name,
      aws_ecs_service.sync.name
    ]
  ) : toset([])
  source = "../monitoring/ecs-alerts"

  name           = format("%s-%s-ecs", var.prefix, each.key)
  cluster_name   = var.ecs_cluster_name == "" ? module.ecs[0].cluster_name : var.ecs_cluster_name
  service_name   = each.key
  sns_topic_arns = [aws_sns_topic.alerts.arn]

}
