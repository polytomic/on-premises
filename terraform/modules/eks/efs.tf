module "efs" {
  source = "cloudposse/efs/aws"

  count = var.create_efs ? 1 : 0

  name    = "${var.prefix}-efs"
  subnets = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  vpc_id  = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  region  = var.region


  allowed_security_group_ids = [module.efs_sg.security_group_id, module.eks.node_security_group_id]

  tags = var.tags
}


module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "${var.prefix}-efs"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "-1"
      cidr_blocks = join(",", local.private_subnet_cidrs)

    },
  ]

  tags = var.tags
}
