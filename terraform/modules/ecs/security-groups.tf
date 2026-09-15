locals {
  task_http_ports = distinct(concat([tonumber(var.polytomic_port)], var.polytomic_mcp_enabled ? [3000] : []))
}

module "database_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  count = var.database_endpoint == "" ? 1 : 0

  name   = "${var.prefix}-database-sg"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  # ingress
  ingress_with_cidr_blocks = var.restrict_ingress_to_security_groups ? [] : [
    {
      from_port   = var.database_port
      to_port     = var.database_port
      protocol    = "tcp"
      description = "Database access from within VPC"
      cidr_blocks = join(",", local.private_subnet_cidrs)
    },
  ]

  computed_ingress_with_source_security_group_id = [{
    from_port                = var.database_port
    to_port                  = var.database_port
    protocol                 = "tcp"
    description              = "Database access from Polytomic tasks"
    source_security_group_id = module.fargate_sg.security_group_id
  }]
  number_of_computed_ingress_with_source_security_group_id = 1

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-database-sg"
    }
  )
}


module "fargate_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name   = "${var.prefix}-fargate_task"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  # ingress
  ingress_with_cidr_blocks = var.restrict_ingress_to_security_groups ? [] : concat(
    [
      {
        from_port   = var.polytomic_port
        to_port     = var.polytomic_port
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
      },
    ],
    var.polytomic_mcp_enabled && var.polytomic_port != "3000" ? [
      {
        from_port   = 3000
        to_port     = 3000
        protocol    = "tcp"
        cidr_blocks = "0.0.0.0/0"
      },
    ] : []
  )

  computed_ingress_with_source_security_group_id = flatten([
    for sg in local.lb_sgs : [
      for port in local.task_http_ports : {
        from_port                = port
        to_port                  = port
        protocol                 = "tcp"
        description              = "HTTP access from Polytomic load balancer"
        source_security_group_id = sg
      }
    ]
  ])
  number_of_computed_ingress_with_source_security_group_id = length(local.lb_sgs) * length(local.task_http_ports)

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-fargate_task"
    }
  )
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

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-efs"
    }
  )
}


module "lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  count = length(var.load_balancer_security_groups) == 0 ? 1 : 0

  name   = "${var.prefix}-lb"
  vpc_id = var.vpc_id == "" ? module.vpc[0].vpc_id : var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = "0.0.0.0/0"

    },
    {
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      cidr_blocks = "0.0.0.0/0"

    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.prefix}-lb"
    }
  )
}
