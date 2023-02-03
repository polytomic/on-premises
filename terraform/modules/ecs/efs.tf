module "efs" {
  source = "cloudposse/efs/aws"

  name    = "${var.prefix}-efs"
  subnets = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  vpc_id  = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  region  = var.region


  allowed_security_group_ids = concat(var.additional_ecs_security_groups, [module.efs_sg.security_group_id, module.fargate_sg.security_group_id])

  tags = var.tags
}
