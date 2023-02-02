module "scheduled_task" {
  count = var.enable_stats ? 1 : 0

  source                                      = "cn-terraform/ecs-fargate-scheduled-task/aws"
  version                                     = "1.0.22"
  name_prefix                                 = var.prefix
  ecs_cluster_arn                             = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
  event_rule_name                             = "polytomic-stats-reporter"
  ecs_execution_task_role_arn                 = aws_iam_role.polytomic_ecs_execution_role.arn
  ecs_task_role_arn                           = aws_iam_role.polytomic_ecs_task_role.arn
  event_rule_schedule_expression              = var.stats_cron
  event_target_ecs_target_task_definition_arn = aws_ecs_task_definition.stats_reporter[0].arn
  event_target_ecs_target_subnets             = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  event_rule_role_arn                         = aws_iam_role.polytomic_stats_reporter_role[0].arn

}

resource "aws_ecs_task_definition" "stats_reporter" {
  count = var.enable_stats ? 1 : 0

  family = "${var.prefix}-stats-reporter"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048

  task_role_arn      = aws_iam_role.polytomic_ecs_task_role.arn
  execution_role_arn = aws_iam_role.polytomic_ecs_execution_role.arn
  tags               = var.tags




  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile(
    "${path.module}/task-definitions/stats-reporter.json.tftpl",
    merge(local.environment,
      {
        bucket = "${var.prefix}-${var.bucket_prefix}${local.polytomic_stats_bucket}",
        format = var.stats_format,
      }
  ))

}
