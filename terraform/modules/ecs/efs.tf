module "efs" {
  source  = "cloudposse/efs/aws"
  version = "~> 0.35.0"

  name    = "${var.prefix}-efs"
  subnets = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  vpc_id  = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  region  = var.region


  allowed_security_group_ids = [module.efs_sg.security_group_id, module.fargate_sg.security_group_id]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-efs"
    }
  )
}
