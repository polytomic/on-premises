module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  count = var.vpc_id == "" ? 1 : 0

  name = var.prefix
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

data "aws_subnet" "subnet" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}


resource "aws_vpc_endpoint" "s3" {
  count           = var.vpc_id == "" ? 1 : 0
  vpc_id          = module.vpc[0].vpc_id
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = module.vpc[0].private_route_table_ids
  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-s3-endpoint"
    }
  )
}
