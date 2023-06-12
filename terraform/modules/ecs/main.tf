data "aws_caller_identity" "current" {}


resource "random_password" "deployment_api_key" {
  count  = var.polytomic_deployment_api_key == "" ? 1 : 0
  length = 64
}

locals {

  # We (unfortuantely) need to manually escape the double quotes in the JSON
  # string
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition#argument-reference
  #
  # This first bit will create a list of strings, each of which is escaped JSON
  raw_links = [for v in var.polytomic_deployment_links :
    format("{\\\"name\\\": \\\"%s\\\", \\\"url\\\": \\\"%s\\\"}", v.name, v.url)
  ]
  # This will join the list of strings into a single string
  links = "[ ${join(", ", [for s in local.raw_links : format("%s", s)])} ]"

  # tags is var.tags converted to a string of key=value pairs
  tags = join(",", [for key, value in var.tags : "${key}=${value}"])


  private_subnet_cidrs       = var.vpc_id == "" ? module.vpc[0].private_subnets_cidr_blocks : [for s in data.aws_subnet.subnet : s.cidr_block]
  polytomic_export_bucket    = "exports"
  polytomic_execution_bucket = "executions"
  polytomic_artifact_bucket  = "artifacts"
  polytomic_stats_bucket     = "stats"
  redis_auth_token           = var.redis_auth_token != "" ? var.redis_auth_token : var.redis_endpoint == "" ? random_password.redis[0].result : ""
  database_url               = var.database_endpoint == "" ? "postgres://${var.database_username}:${module.database[0].db_instance_password}@${module.database[0].db_instance_address}:${var.database_port}/${var.database_name}" : var.database_endpoint
  redis_url                  = var.redis_endpoint == "" ? "rediss://:${local.redis_auth_token}@${module.redis[0].elasticache_replication_group_primary_endpoint_address}:${var.redis_port}" : var.redis_endpoint
  monitoring_email           = "monitoring-${var.polytomic_deployment}@polytomic.com"
  alert_emails               = var.alert_emails == [] ? [local.monitoring_email] : concat(var.alert_emails, [local.monitoring_email])
  parsed_polytomic_url       = regex("(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?(?P<path>[^?#]*)(?:\\?(?P<query>[^#]*))?(?:#(?P<fragment>.*))?", var.polytomic_url)


  standard_env_vars = {
    ROOT_USER                           = var.polytomic_root_user,
    LOCAL_DATA                          = var.polytomic_data_path != "",
    LOCAL_DATA_PATH                     = "${var.polytomic_data_path}/models",
    JOB_PAYLOAD_PATH                    = "${var.polytomic_data_path}/jobs",
    AWS_REGION                          = var.region,
    DEPLOYMENT                          = var.polytomic_deployment,
    DEPLOYMENT_KEY                      = var.polytomic_deployment_key,
    DEPLOYMENT_API_KEY                  = var.polytomic_deployment_api_key == "" ? random_password.deployment_api_key[0].result : var.polytomic_deployment_api_key,
    DEPLOYMENT_LINKS                    = local.links,
    DATABASE_URL                        = local.database_url,
    REDIS_URL                           = local.redis_url,
    POLYTOMIC_URL                       = var.polytomic_url == "" ? "http://${aws_alb.main.dns_name}/" : local.parsed_polytomic_url.scheme == null ? "https://${var.polytomic_url}" : "${var.polytomic_url}",
    EXECUTION_LOG_BUCKET                = "${var.prefix}-${var.bucket_prefix}${local.polytomic_execution_bucket}",
    EXECUTION_LOG_REGION                = var.region,
    EXPORT_QUERY_BUCKET                 = "${var.prefix}-${var.bucket_prefix}${local.polytomic_export_bucket}",
    EXPORT_QUERY_REGION                 = var.region,
    RECORD_LOG_DISABLED                 = var.polytomic_record_log_disabled,
    DEFAULT_OPERATIONAL_BUCKET          = "s3://${var.prefix}-${var.bucket_prefix}${local.polytomic_execution_bucket}?region=${var.region}"
    LOG_LEVEL                           = var.polytomic_log_level,
    GOOGLE_CLIENT_ID                    = var.polytomic_google_client_id,
    GOOGLE_CLIENT_SECRET                = var.polytomic_google_client_secret,
    TASK_EXECUTOR_ENABLED               = true,
    TASK_EXECUTOR_CPU                   = var.polytomic_resource_sync_cpu,
    TASK_EXECUTOR_MEMORY_RESERVATION    = var.polytomic_resource_sync_memory,
    FARGATE_EXECUTOR_SUBNETS            = join(",", var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids),
    FARGATE_EXECUTOR_SECURITY_GROUPS    = join(",", concat(var.additional_ecs_security_groups, [module.fargate_sg.security_group_id]))
    SINGLE_PLAYER                       = var.polytomic_single_player,
    WORKOS_API_KEY                      = var.polytomic_workos_api_key,
    WORKOS_CLIENT_ID                    = var.polytomic_workos_client_id,
    GA_MEASUREMENT_ID                   = var.polytomic_ga_measurement_id,
    ENABLED_BACKENDS                    = join(",", var.polytomic_enabled_backends)
    CAPTURE_SYNC_LOGS                   = var.polytomic_sync_logging_enabled
    MSSQL_TX_ISOLATION                  = var.polytomic_mssql_tx_isolation
    EXECUTION_LOGS_V2                   = var.polytomic_use_logger
    TASK_EXECUTOR_CLEANUP_DELAY_SECONDS = 30
    RETAIN_CACHE_DIR                    = "/var/polytomic/retained"
    TX_BUFFER_SIZE                      = var.polytomic_tx_buffer_size
    QUERY_WORKERS                       = var.polytomic_query_worker_count
    QUERY_RUNNER_EXCLUDE                = join(",", var.polytomic_query_runner_exclude_dbs)
    LEGACY_CONFIG                       = var.polytomic_legacy_config
    SEND_LOGS                           = var.polytomic_managed_logs && var.polytomic_use_logger
    ENV                                 = var.polytomic_deployment
    RECORD_LOG_BUCKET                   = "${var.prefix}-${var.bucket_prefix}${local.polytomic_execution_bucket}",
    RECORD_LOG_REGION                   = var.region
    VECTOR_INTERNAL                     = true
    TASK_EXECUTOR_TAGS                  = local.tags
  }

  environment = {
    web_memory             = var.polytomic_resource_web_memory
    sync_memory            = var.polytomic_resource_sync_memory
    worker_memory          = var.polytomic_resource_worker_memory
    scheduler_memory       = var.polytomic_resource_scheduler_memory
    image                  = var.polytomic_image,
    region                 = var.region,
    polytomic_port         = var.polytomic_port,
    mount_path             = var.polytomic_data_path,
    polytomic_logger       = false
    polytomic_logger_image = var.polytomic_logger_image,

    polytomic_dd_agent       = var.polytomic_use_dd_agent,
    polytomic_dd_agent_image = var.polytomic_dd_agent_image,

    env = merge(local.standard_env_vars, var.extra_environment)
  }

}
