locals {
  thresholds = {
    CPUUtilizationHighThreshold    = min(max(var.cpu_utilization_high_threshold, 0), 100)
    MemoryUtilizationHighThreshold = min(max(var.memory_utilization_high_threshold, 0), 100)
    RunningTasksCountThreshold     = 1
  }
  dimensions_map = {
    "service" = {
      "ClusterName" = var.cluster_name
      "ServiceName" = var.service_name
    }
    "cluster" = {
      "ClusterName" = var.cluster_name
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_high" {
  alarm_name          = format("%s_cpu_utilization_high", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["CPUUtilizationHighThreshold"]
  alarm_description   = "Average ECS CPU utilization over the threshold for the last 2 minutes too high"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = local.dimensions_map[var.service_name == "" ? "cluster" : "service"]

}

resource "aws_cloudwatch_metric_alarm" "memory_utilization_high" {
  alarm_name          = format("%s_memory_utilization_high", var.name)
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["MemoryUtilizationHighThreshold"]
  alarm_description   = "Average ECS memory utilization over the threshold for the last 2 minutes too high"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = local.dimensions_map[var.service_name == "" ? "cluster" : "service"]
}

resource "aws_cloudwatch_metric_alarm" "running_tasks_low" {
  alarm_name          = format("%s_running_tasks_low", var.name)
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = "120"
  statistic           = "Average"
  threshold           = local.thresholds["RunningTasksCountThreshold"]
  alarm_description   = "At least one ECS task is not running"
  alarm_actions       = var.sns_topic_arns
  ok_actions          = var.sns_topic_arns

  dimensions = local.dimensions_map[var.service_name == "" ? "cluster" : "service"]
}

resource "aws_cloudwatch_event_rule" "oom" {
  name        = "capture-oom"
  description = "Capture Out of Memory contains events"

  event_pattern = jsonencode({
    source = [
      "aws.ecs"
    ]
    detail-type = [
      "ECS Task State Change"
    ]
    detail = {
      desiredStatus = [
        "STOPPED"
      ]
      lastStatus = [
        "STOPPED"
      ]
      containers = {
        reason = [
          { prefix = "OutOfMemory" }
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  arn       = var.sns_topic_arns[0]
  rule      = aws_cloudwatch_event_rule.oom.name

  input_transformer {
    input_paths = {
      taskArn = "$.detail.taskArn",
    }
    input_template = <<EOF
Task '<taskArn>' has been stopped due to OutOfMemory
EOF
  }
}

resource "aws_sns_topic_policy" "oom" {
  arn = aws_sns_topic.test.arn

  policy = data.aws_iam_policy_document.oom_topic_policy.json
}

data "aws_iam_policy_document" "oom_topic_policy" {
  statement {
    sid       = "SnsOOMTopicPolicy"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = var.sns_topic_arns
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }

  statement {
    actions = [
      "sns:GetTopicAttributes",
      "sns:SetTopicAttributes",
      "sns:AddPermission",
      "sns:RemovePermission",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:Publish",
      "sns:Receive",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        var.account-id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = var.sns_topic_arns

    sid = "__default_statement_ID"
  }
}
