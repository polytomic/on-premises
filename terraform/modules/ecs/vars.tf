variable "prefix" {
  default = ""
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region to use"
}

variable "aws_profile" {
  default     = "default"
  description = "AWS profile to use"
}

variable "polytomic_image" {
  default     = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest"
  description = "Docker image to use for the Polytomic ECS cluster"
}

variable "polytomic_single_player" {
  default     = false
  description = "Whether to use the single player mode"
}

variable "polytomic_google_client_id" {
  default     = ""
  description = "Google OAuth Client ID, obtained by creating a OAuth 2.0 Client ID"
}

variable "polytomic_google_client_secret" {
  default     = ""
  description = "Google OAuth Client Secret, obtained by creating a OAuth 2.0 Client ID"
}

variable "polytomic_url" {
  default     = ""
  description = "Base URL for accessing Polytomic. This will be used when redirecting back from Google and other integrations after authenticating with OAuth."
}

variable "polytomic_port" {
  default     = "80"
  description = "Port on which Polytomic is listening"
}
variable "polytomic_root_user" {
  description = "The email address to use when starting for the first time; this user will be able to add additional users and configure Polytomic"
  default     = ""
}

variable "polytomic_data_path" {
  description = "Filesystem path to local data cache"
  default     = "/var/polytomic"
}

variable "polytomic_preflight_check" {
  description = "Whether to run a preflight check"
  default     = true
}

variable "polytomic_deployment" {
  description = "A unique identifier for your on premises deploy, provided by Polytomic"
  default     = ""
}

variable "polytomic_deployment_key" {
  description = "The license key for your deployment, provided by Polytomic"
  default     = ""
}

variable "polytomic_log_level" {
  default     = "info"
  description = "The log level to use for Polytomic"
}

variable "polytomic_sync_logging_enabled" {
  default     = true
  description = "Record execution logs for syncs performed via Polytomic"
}

variable "polytomic_workos_api_key" {
  description = "The API key for the WorkOS account to use for Polytomic"
  default     = ""
}

variable "polytomic_workos_client_id" {
  description = "The WorkOS client ID"
  default     = ""
}

variable "polytomic_workspace_name" {
  description = "Name of first Polytomic workspace"
  default     = ""
}

variable "polytomic_sso_domain" {
  description = "Domain for SSO users of first Polytomic workspace; ie, example.com."
  default     = ""
}

variable "polytomic_workos_org_id" {
  description = "WorkOS organization ID for workspace SSO"
  default     = ""
}

variable "polytomic_bootstrap" {
  default     = false
  description = "Whether to bootstrap Polytomic"
}

variable "polytomic_deployment_api_key" {
  description = "API key used to authenticate with the Polytomic management API"
  default     = ""
}

variable "polytomic_enabled_backends" {
  description = "List of backends to enable"
  default     = []
}

variable "polytomic_ga_measurement_id" {
  description = "Google Analytics Measurement ID"
  default     = ""
}

variable "polytomic_resource_web_cpu" {
  description = "CPU units for the web container"
  default     = 2048 // 2 vCPU
}

variable "polytomic_resource_web_memory" {
  description = "Memory units for the web container"
  default     = 4096 // 4 GB
}

variable "polytomic_resource_worker_cpu" {
  description = "CPU units for the worker container"
  default     = 2048
}

variable "polytomic_resource_worker_memory" {
  description = "Memory units for the worker container"
  default     = 4096 // 4 GB
}

variable "polytomic_resource_sync_cpu" {
  description = "CPU units for the sync container"
  default     = 2048 // 2 vCPU
}

variable "polytomic_resource_sync_memory" {
  description = "Memory units for the sync container"
  default     = 8192 // 8 GB
}

variable "polytomic_mssql_tx_isolation" {
  description = "Transaction isolation level for MSSQL connections"
  default     = ""
}
variable "polytomic_use_logger" {
  description = "Use polytomic log aggregator"
  default     = true
}


variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  default     = []
}


variable "public_subnet_ids" {
  description = "Public subnet IDs"
  default     = []
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "VPC availability zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_private_subnets" {
  description = "VPC private subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "vpc_public_subnets" {
  description = "VPC public subnets"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

}

variable "redis_endpoint" {
  description = "Redis endpoint"
  default     = ""
}

variable "redis_port" {
  description = "Redis port"
  default     = 6379
}

variable "redis_cluster_size" {
  description = "Redis cluster size"
  default     = "1"
}

variable "redis_instance_type" {
  description = "Redis instance type"
  default     = "cache.t2.micro"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  default     = "6.2"
}

variable "redis_family" {
  description = "Redis family"
  default     = "redis6.x"
}

variable "redis_at_rest_encryption_enabled" {
  description = "Redis at rest encryption enabled"
  default     = "true"
}

variable "redis_transit_encryption_enabled" {
  description = "Redis transit encryption enabled"
  default     = "true"
}

variable "redis_auth_token" {
  description = "Redis auth token"
  default     = ""
}

variable "redis_snapshot_window" {
  description = "Redis snapshot window"
  default     = "04:00-06:00"
}


variable "redis_maintenance_window" {
  description = "Redis maintenance window"
  default     = "mon:03:00-mon:04:00"

}

variable "redis_snapshot_retention_limit" {
  description = "Redis snapshot retention limit"
  default     = "7"

}

variable "database_endpoint" {
  description = "Database Endpoint"
  default     = ""
}


variable "database_name" {
  description = "Database Name"
  default     = "polytomic"
}


variable "database_username" {
  description = "Database username"
  default     = "polytomic"
}

variable "database_port" {
  description = "Database port"
  default     = 5432
}

variable "database_multi_az" {
  description = "Multi-AZ database"
  default     = true
}

variable "database_allocated_storage" {
  description = "Database allocated storage"
  default     = 20
}

variable "database_max_allocated_storage" {
  description = "Database max allocated storage"
  default     = 100
}

variable "database_backup_retention" {
  description = "Database backup retention"
  default     = 30
}

variable "database_engine" {
  description = "Database engine"
  default     = "postgres"
}

variable "database_auto_minor_version_upgrade" {
  description = "Database auto minor version upgrade"
  default     = false
}

variable "database_engine_version" {
  description = "Database engine version"
  default     = "14.1"
}

variable "database_family" {
  description = "Database family"
  default     = "postgres14"
}

variable "database_major_engine_version" {
  description = "Database major engine version"
  default     = "14"
}

variable "database_instance_class" {
  description = "Database instance class"
  default     = "db.t3.small"
}

variable "database_maintenance_window" {
  description = "Database maintenance window"
  default     = "Mon:00:00-Mon:03:00"
}

variable "database_backup_window" {
  description = "Database backup window"
  default     = "03:00-06:00"
}

variable "database_enabled_cloudwatch_logs_exports" {
  description = "Database enabled cloudwatch logs exports"
  default     = ["postgresql", "upgrade"]
}

variable "database_create_cloudwatch_log_group" {
  description = "Database create cloudwatch log group"
  default     = true
}

variable "database_skip_final_snapshot" {
  description = "Database skip final snapshot"
  default     = false
}

variable "database_deletion_protection" {
  description = "Database deletion protection"
  default     = true
}

variable "database_performance_insights_enabled" {
  description = "Database performance insights enabled"
  default     = true
}

variable "database_performance_insights_retention_period" {
  description = "Database performance insights retention period"
  default     = 7
}

variable "database_create_monitoring_role" {
  description = "Database create monitoring role"
  default     = true
}


variable "database_monitoring_role_name" {
  description = "Database monitoring role name"
  default     = "polytomic-monitoring-role"
}

variable "database_monitoring_interval" {
  description = "Database monitoring interval"
  default     = 60
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  default     = ""
}


variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}


variable "bucket_prefix" {
  description = "Bucket prefix"
  default     = "polytomic"
}

variable "polytomic_record_log_disabled" {
  description = "Globally disable record logging for this deployment"
  default     = false
}

variable "stats_cron" {
  description = "Stats cron"
  // Default is every day at midnight
  default = "cron(0 0 * * ? *)"
}

variable "stats_format" {
  description = "Output format for stats reporter"
  default     = "json"
}

variable "enable_stats" {
  description = "enable automatic stats reporting"
  default     = false
}

variable "enable_monitoring" {
  description = "enable automatic monitoring"
  default     = false
}

variable "alert_emails" {
  description = "Email addresses to send alerts to"
  type        = list(string)
  default     = []
}
