provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "../../modules/ecs"

  prefix = "polytomic"
  tags = {
    Owner       = "polytomic"
    Environment = "staging"
    Billing     = "R/D"
  }

  region = "us-east-1"

  ####### Polytomic settings #######
  polytomic_image = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:rel2022.06.21.01"

  polytomic_root_user          = "user@example.com"
  polytomic_deployment         = "DEPLOYMENT"
  polytomic_deployment_key     = "DEPLOYMENT_KEY"
  polytomic_deployment_api_key = "DEPLOYMENT_API_KEY"

  polytomic_google_client_id     = "GOOGLE_ID"
  polytomic_google_client_secret = "GOOGLE_SECRET"
  polytomic_url                  = ""

  polytomic_single_player       = false
  polytomic_bootstrap           = true
  polytomic_record_log_disabled = false

  # valid values are debug, info, warn, error; the default is info
  polytomic_log_level = "info"

  ####### VPC settings #######
  #
  # Use this to set the VPC ID to use for the VPC.
  # If not set, the VPC will be created.
  # vpc_id = "vpc-123456789"
  vpc_id             = ""
  private_subnet_ids = []
  public_subnet_ids  = []
  #
  # New VPC settings
  vpc_cidr            = "10.0.0.0/16"
  vpc_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  ####### ECS settings #######
  #
  # Use this if you want to use an existing ECS cluster.
  # If not set, a new ECS cluster will be created.
  # ecs_cluster_name = "my-ecs-cluster"
  ecs_cluster_name = ""


  ####### Redis settings #######
  #
  # Use this if you already have a Redis endpoint set up.
  # If left blank, we'll create a new Redis instance for you using the settings below.
  # redis_endpoint = redis://:password@host:6379/"
  redis_endpoint = ""
  #
  # New Redis instance settings
  redis_cluster_size = 1

  redis_port           = 6379
  redis_instance_type  = "cache.t2.micro"
  redis_engine_version = "6.2"
  redis_family         = "redis6.x"

  redis_at_rest_encryption_enabled = true
  redis_transit_encryption_enabled = true


  redis_maintenance_window       = "mon:03:00-mon:04:00"
  redis_snapshot_window          = "04:00-06:00"
  redis_snapshot_retention_limit = 7

  ####### Database settings #######
  #
  # Use this if you already have a database endpoint set up.
  # If left blank, we'll create a new database instance for you using the settings below.
  # database_endpoint = "postgres://user:password@host:port/database"
  database_endpoint = ""
  #
  # New database instance settings
  database_username             = "polytomic"
  database_name                 = "polytomic"
  database_port                 = 5432
  database_engine               = "postgres"
  database_engine_version       = "14.1"
  database_family               = "postgres14"
  database_major_engine_version = "14"
  database_instance_class       = "db.t3.small"

  database_multi_az              = true
  database_allocated_storage     = 20
  database_max_allocated_storage = 100
  database_backup_retention      = 30
  database_maintenance_window    = "Mon:00:00-Mon:03:00"
  database_backup_window         = "03:00-06:00"
  database_skip_final_snapshot   = false
  database_deletion_protection   = false


  database_enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  database_create_cloudwatch_log_group           = false
  database_performance_insights_enabled          = true
  database_performance_insights_retention_period = 7

  database_create_monitoring_role = true
  database_monitoring_interval    = 60
  database_monitoring_role_name   = "monitoring-role"
}
