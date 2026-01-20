variable "prefix" {
  description = "Prefix for all resources"
  default     = "polytomic"

}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
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

variable "vpc_id" {
  description = "VPC ID"
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  default     = "t3.small"
}


variable "min_size" {
  description = "Minimum number of nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of nodes"
  default     = 4
}

variable "desired_size" {
  description = "Desired number of nodes"
  default     = 3
}

variable "tags" {
  description = "Tags"
  default     = {}
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
  default     = "false"
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
  default     = "14.7"
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


variable "create_redis" {
  description = "Whether to create a redis instance"
  default     = true
}

variable "create_postgres" {
  description = "Whether to create a postgres instance"
  default     = true
}

variable "create_efs" {
  description = "Whether to create an EFS instance"
  default     = true
}


variable "bucket_name" {
  description = "Optional: Exact S3 bucket name to use. If not specified, defaults to '<prefix>-operations'. Use this to specify an existing bucket or ensure global uniqueness."
  default     = ""
}
