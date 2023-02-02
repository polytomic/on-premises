module "redis" {
  source = "umotif-public/elasticache-redis/aws"

  count = var.create_redis ? 1 : 0

  name_prefix        = var.prefix
  num_cache_clusters = var.redis_cluster_size
  node_type          = var.redis_instance_type

  engine_version           = var.redis_engine_version
  port                     = var.redis_port
  maintenance_window       = var.redis_maintenance_window
  snapshot_window          = var.redis_snapshot_window
  snapshot_retention_limit = var.redis_snapshot_retention_limit

  automatic_failover_enabled = true

  at_rest_encryption_enabled = var.redis_at_rest_encryption_enabled
  transit_encryption_enabled = var.redis_transit_encryption_enabled
  auth_token                 = local.redis_auth_token

  apply_immediately = true
  family            = var.redis_family

  subnet_ids = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  vpc_id     = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  ingress_cidr_blocks = local.private_subnet_cidrs

  tags = var.tags
}

resource "random_password" "redis" {
  count   = var.redis_auth_token == "" && var.create_redis ? 1 : 0
  length  = 32
  special = false
}
