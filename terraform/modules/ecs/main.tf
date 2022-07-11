resource "random_password" "deployment_api_key" {
  length = 64
}

locals {
  private_subnet_cidrs       = var.vpc_id == "" ? module.vpc[0].private_subnets_cidr_blocks : [for s in data.aws_subnet.subnet : s.cidr_block]
  polytomic_export_bucket    = "exports"
  polytomic_execution_bucket = "executions"
  polytomic_artifact_bucket  = "artifacts"
  redis_auth_token           = var.redis_auth_token != "" ? var.redis_auth_token : var.redis_endpoint == "" ? random_password.redis[0].result : ""
  database_url               = var.database_endpoint == "" ? "postgres://${var.database_username}:${module.database[0].db_instance_password}@${module.database[0].db_instance_address}:${var.database_port}/${var.database_name}" : var.database_endpoint
  redis_url                  = var.redis_endpoint == "" ? "rediss://:${local.redis_auth_token}@${module.redis[0].elasticache_replication_group_primary_endpoint_address}:${var.redis_port}" : var.redis_endpoint

  environment = {
    image          = var.polytomic_image,
    region         = var.region,
    polytomic_port = var.polytomic_port,
    mount_path     = var.polytomic_data_path,
    env = {
      ROOT_USER                        = var.polytomic_root_user,
      LOCAL_DATA                       = var.polytomic_data_path != "",
      LOCAL_DATA_PATH                  = var.polytomic_data_path,
      AWS_REGION                       = var.region,
      DEPLOYMENT                       = var.polytomic_deployment,
      DEPLOYMENT_KEY                   = var.polytomic_deployment_key,
      DEPLOYMENT_API_KEY               = random_password.deployment_api_key.result
      DATABASE_URL                     = local.database_url,
      REDIS_URL                        = local.redis_url,
      POLYTOMIC_URL                    = var.polytomic_url == "" ? "http://${aws_alb.main.dns_name}/" : var.polytomic_url,
      EXECUTION_LOG_BUCKET             = "${var.prefix}-${var.bucket_prefix}-${local.polytomic_execution_bucket}",
      EXECUTION_LOG_REGION             = var.region,
      EXPORT_QUERY_BUCKET              = "${var.prefix}-${var.bucket_prefix}-${local.polytomic_export_bucket}",
      EXPORT_QUERY_REGION              = var.region,
      RECORD_LOG_DISABLED              = var.record_log_disabled
      LOG_LEVEL                        = var.polytomic_log_level,
      GOOGLE_CLIENT_ID                 = var.polytomic_google_client_id,
      GOOGLE_CLIENT_SECRET             = var.polytomic_google_client_secret,
      TASK_EXECUTOR_ENABLED            = true,
      TASK_EXECUTOR_CPU                = 2048,
      TASK_EXECUTOR_MEMORY_RESERVATION = 4096,
      FARGATE_EXECUTOR_SUBNETS         = join(",", var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids),
      FARGATE_EXECUTOR_SECURITY_GROUPS = module.fargate_sg.security_group_id,
      SINGLE_PLAYER                    = var.polytomic_single_player,
      WORKOS_API_KEY                   = var.polytomic_workos_api_key,
      WORKOS_CLIENT_ID                 = var.polytomic_workos_client_id,
    }
  }
}
