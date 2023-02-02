module "database" {
  source = "terraform-aws-modules/rds/aws"

  count = var.create_postgres ? 1 : 0

  identifier = "${var.prefix}-database"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                     = var.database_engine
  engine_version             = var.database_engine_version
  auto_minor_version_upgrade = var.database_auto_minor_version_upgrade
  family                     = var.database_family
  major_engine_version       = var.database_major_engine_version
  instance_class             = var.database_instance_class
  allocated_storage          = var.database_allocated_storage
  max_allocated_storage      = var.database_max_allocated_storage

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = var.database_name
  username = var.database_username
  port     = var.database_port
  multi_az = var.database_multi_az


  create_db_subnet_group = true
  subnet_ids             = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  vpc_security_group_ids = [module.database_sg[0].security_group_id]

  maintenance_window              = var.database_maintenance_window
  backup_window                   = var.database_backup_window
  enabled_cloudwatch_logs_exports = var.database_enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group     = var.database_create_cloudwatch_log_group

  backup_retention_period = var.database_backup_retention
  skip_final_snapshot     = var.database_skip_final_snapshot
  deletion_protection     = var.database_deletion_protection

  performance_insights_enabled          = var.database_performance_insights_enabled
  performance_insights_retention_period = var.database_performance_insights_retention_period
  create_monitoring_role                = var.database_create_monitoring_role
  monitoring_interval                   = var.database_monitoring_interval
  monitoring_role_name                  = var.database_monitoring_role_name

  tags = var.tags

}


module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  count = var.create_postgres ? 1 : 0

  name   = "${var.prefix}-database-sg"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.database_port
      to_port     = var.database_port
      protocol    = "tcp"
      description = "Database access from within VPC"
      cidr_blocks = join(",", local.private_subnet_cidrs)
    },
  ]

  tags = var.tags
}
