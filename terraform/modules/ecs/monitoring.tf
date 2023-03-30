resource "aws_kms_key" "alerts" {
  count = var.enable_monitoring ? 1 : 0
}

resource "aws_sns_topic" "alerts" {
  count             = var.enable_monitoring ? 1 : 0
  name              = "${var.prefix}-alerts"
  kms_master_key_id = aws_kms_key.alerts[0].arn
}

resource "aws_sns_topic_subscription" "alert_emails" {
  for_each  = var.enable_monitoring ? toset(local.alert_emails) : toset([])
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = each.key
}


module "rds-alerts" {
  source = "../monitoring/rds-alerts"
  count  = var.database_endpoint == "" && var.enable_monitoring ? 1 : 0

  name           = format("%s-database", var.prefix)
  db_instance_id = module.database[0].db_instance_id
  sns_topic_arns = [aws_sns_topic.alerts[0].arn]

}

module "elasticache-alerts" {
  source = "../monitoring/elasticache-alerts"
  count  = var.redis_endpoint == "" && var.enable_monitoring ? 1 : 0

  name             = format("%s-elasticache", var.prefix)
  cache_cluster_id = module.redis[0].elasticache_replication_group_member_clusters
  sns_topic_arns   = [aws_sns_topic.alerts[0].arn]

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
  sns_topic_arns = [aws_sns_topic.alerts[0].arn]

}


resource "aws_cloudwatch_event_rule" "oom" {
  count       = var.enable_monitoring ? 1 : 0
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
  count = var.enable_monitoring ? 1 : 0

  arn  = aws_sns_topic.alerts[0].arn
  rule = aws_cloudwatch_event_rule.oom[0].name

  input_transformer {
    input_paths = {
      taskArn = "$.detail.taskArn",
    }
    input_template = <<EOF
"Task \"<taskArn>\" has been stopped due to OutOfMemory"
EOF
  }
}

resource "aws_sns_topic_policy" "oom" {
  count = var.enable_monitoring ? 1 : 0

  arn    = aws_sns_topic.alerts[0].arn
  policy = data.aws_iam_policy_document.oom_topic_policy[0].json
}

data "aws_iam_policy_document" "oom_topic_policy" {
  count = var.enable_monitoring ? 1 : 0

  statement {
    sid       = "SnsOOMTopicPolicy"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts[0].arn]
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
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.alerts[0].arn]

    sid = "__default_statement_ID"
  }
}
