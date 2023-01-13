module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  count = var.ecs_cluster_name == "" ? 1 : 0

  cluster_name = "${var.prefix}-cluster"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = module.log_group.cloudwatch_log_group_name
      }
    }
  }

  cluster_settings = {
    name  = "containerInsights"
    value = var.ecs_enable_container_insights ? "enabled" : "disabled"
  }


  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  tags = var.tags
}

data "aws_ecs_cluster" "cluster" {
  count        = var.ecs_cluster_name != "" ? 1 : 0
  cluster_name = var.ecs_cluster_name
}
