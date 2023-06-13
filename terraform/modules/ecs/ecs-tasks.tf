resource "aws_ecs_task_definition" "web" {
  family = "${var.prefix}-web"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.polytomic_resource_web_cpu
  memory                   = var.polytomic_resource_web_memory

  task_role_arn      = aws_iam_role.polytomic_ecs_task_role.arn
  execution_role_arn = aws_iam_role.polytomic_ecs_execution_role.arn
  tags               = var.tags


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile(
    "${path.module}/task-definitions/web.json.tftpl", local.environment
  )

  volume {
    name = "polytomic"

    efs_volume_configuration {
      file_system_id          = module.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

}

resource "aws_ecs_task_definition" "worker" {
  family = "${var.prefix}-worker"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.polytomic_resource_worker_cpu
  memory                   = var.polytomic_resource_worker_memory

  task_role_arn      = aws_iam_role.polytomic_ecs_task_role.arn
  execution_role_arn = aws_iam_role.polytomic_ecs_execution_role.arn
  tags               = var.tags


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile(
    "${path.module}/task-definitions/worker.json.tftpl", local.environment
  )

  volume {
    name = "polytomic"

    efs_volume_configuration {
      file_system_id          = module.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

}

resource "aws_ecs_task_definition" "sync" {
  family = "${var.prefix}-sync"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.polytomic_resource_sync_cpu
  memory                   = var.polytomic_resource_sync_memory

  task_role_arn      = aws_iam_role.polytomic_ecs_task_role.arn
  execution_role_arn = aws_iam_role.polytomic_ecs_execution_role.arn
  tags               = var.tags


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile(
    "${path.module}/task-definitions/sync.json.tftpl", local.environment
  )

  volume {
    name = "polytomic"

    efs_volume_configuration {
      file_system_id          = module.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

}

resource "aws_ecs_task_definition" "scheduler" {
  family = "${var.prefix}-scheduler"

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.polytomic_resource_scheduler_cpu
  memory                   = var.polytomic_resource_scheduler_memory

  task_role_arn      = aws_iam_role.polytomic_ecs_task_role.arn
  execution_role_arn = aws_iam_role.polytomic_ecs_execution_role.arn
  tags               = var.tags


  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = templatefile(
    "${path.module}/task-definitions/scheduler.json.tftpl", local.environment
  )

  volume {
    name = "polytomic"

    efs_volume_configuration {
      file_system_id          = module.efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2999
    }
  }

}

resource "aws_ecs_service" "web" {
  name            = "${var.prefix}-web"
  cluster         = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 1

  enable_execute_command            = true
  health_check_grace_period_seconds = 60
  platform_version                  = "1.4.0"

  launch_type = "FARGATE"
  tags        = var.tags

  propagate_tags = "TASK_DEFINITION"



  network_configuration {
    subnets          = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
    assign_public_ip = false
    security_groups  = concat(var.additional_ecs_security_groups, [module.fargate_sg.security_group_id])

  }

  load_balancer {
    target_group_arn = aws_alb_target_group.polytomic.arn
    container_name   = "web"
    container_port   = var.polytomic_port
  }
}

resource "aws_ecs_service" "worker" {
  name            = "${var.prefix}-worker"
  cluster         = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = 1

  enable_execute_command = true
  platform_version       = "1.4.0"

  launch_type = "FARGATE"
  tags        = var.tags


  propagate_tags = "TASK_DEFINITION"

  network_configuration {
    subnets          = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
    assign_public_ip = false
    security_groups  = concat(var.additional_ecs_security_groups, [module.fargate_sg.security_group_id])
  }
}

resource "aws_ecs_service" "sync" {
  name            = "${var.prefix}-sync"
  cluster         = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
  task_definition = aws_ecs_task_definition.sync.arn
  desired_count   = var.polytomic_resource_sync_count

  enable_execute_command = true
  platform_version       = "1.4.0"

  launch_type = "FARGATE"
  tags        = var.tags

  propagate_tags = "TASK_DEFINITION"

  network_configuration {
    subnets          = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
    assign_public_ip = false
    security_groups  = concat(var.additional_ecs_security_groups, [module.fargate_sg.security_group_id])
  }
}



resource "aws_ecs_service" "scheduler" {
  name            = "${var.prefix}-scheduler"
  cluster         = var.ecs_cluster_name == "" ? module.ecs[0].cluster_arn : data.aws_ecs_cluster.cluster[0].arn
  task_definition = aws_ecs_task_definition.scheduler.arn
  desired_count   = 1

  enable_execute_command = true
  platform_version       = "1.4.0"

  launch_type = "FARGATE"
  tags        = var.tags

  propagate_tags = "TASK_DEFINITION"


  network_configuration {
    subnets          = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
    assign_public_ip = false
    security_groups  = concat(var.additional_ecs_security_groups, [module.fargate_sg.security_group_id])
  }
}