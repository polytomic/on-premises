locals {
  private_subnet_cidrs = var.vpc_id == "" ? module.vpc[0].private_subnets_cidr_blocks : [for s in data.aws_subnet.subnet : s.cidr_block]
  redis_auth_token     = var.redis_auth_token != "" ? var.redis_auth_token : var.create_redis == "" ? random_password.redis[0].result : ""
}


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
  tags            = var.tags
}

# IAM role for EBS CSI driver
module "ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${var.prefix}-ebs-csi-"

  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

# IAM role for EFS CSI driver
module "efs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${var.prefix}-efs-csi-"

  attach_efs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

  tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.prefix}-cluster"
  kubernetes_version = "1.34"

  vpc_id                 = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id
  subnet_ids             = var.vpc_id == "" ? module.vpc[0].private_subnets : var.private_subnet_ids
  endpoint_public_access = true

  addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      before_compute = true
      most_recent    = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = module.ebs_csi_driver_irsa.iam_role_arn
      most_recent              = true
    }
    aws-efs-csi-driver = {
      service_account_role_arn = module.efs_csi_driver_irsa.iam_role_arn
      most_recent              = true
    }
  }

  eks_managed_node_groups = {
    one = {
      name = "${var.prefix}"

      instance_types = [var.instance_type]

      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

      # Allow nodes to pull images from ECR
      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }

    nfs_ingress = {
      description = "NFS ingress"
      protocol    = "tcp"
      from_port   = 2049
      to_port     = 2049
      type        = "ingress"
      cidr_blocks = module.vpc.*.vpc_cidr_block
    }

  }

  access_entries = var.access_entries

  tags = var.tags
}




