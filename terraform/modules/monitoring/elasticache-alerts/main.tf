locals {
  thresholds = {
    CPUUtilizationThreshold     = min(max(var.cpu_utilization_threshold, 0), 100)
    FreeableMemoryThreshold     = max(var.freeable_memory_threshold, 0)
    CurrentConnectionsThreshold = max(var.current_connections_threshold, 1000)

  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  alarm_name          = format("%s_cpu_utilization_too_high", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationThreshold"]
  alarm_description   = "Average elasticache CPU utilization over the threshold for the last 2 minutes too high"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = {
    CacheClusterId = var.cache_cluster_id[0]
  }
}

resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  alarm_name          = format("%s_freeable_memory_too_low", var.name)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["FreeableMemoryThreshold"]
  alarm_description   = "Average elasticache freeable memory under the threshold for last 2 minutes too high"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = {
    CacheClusterId = var.cache_cluster_id[0]
  }
}

resource "aws_cloudwatch_metric_alarm" "current_connections" {
  alarm_name          = format("%s_current_connections_too_high", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CurrConnections"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["CurrentConnectionsThreshold"]
  alarm_description   = "Average elasticache current connections over last 2 minutes too high"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = {
    CacheClusterId = var.cache_cluster_id[0]
  }
}
