// Minimal working example of the aws-privatelink-rds-lattice module.
//
// Assumes you already have an RDS instance and know its VPC, subnets, and
// security group.

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60, < 7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "rds_identifier" {
  description = "identifier of an existing aws_db_instance"
  type        = string
}

variable "polytomic_aws_account_id" {
  description = "Polytomic's AWS account ID — provided by your SE"
  type        = string
}

data "aws_db_instance" "existing" {
  db_instance_identifier = var.rds_identifier
}

data "aws_vpc" "existing" {
  id = data.aws_db_instance.existing.db_subnet_group.0.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
  tags = {
    Tier = "private"
  }
}

module "polytomic_privatelink" {
  source = "github.com/polytomic/on-premises//terraform/modules/aws-privatelink-rds-lattice"

  vpc_id     = data.aws_vpc.existing.id
  subnet_ids = data.aws_subnets.private.ids

  rds_host              = data.aws_db_instance.existing.address
  rds_port              = data.aws_db_instance.existing.port
  rds_security_group_id = data.aws_db_instance.existing.vpc_security_groups[0]

  polytomic_aws_account_id = var.polytomic_aws_account_id
}

output "resource_configuration_arn" {
  description = "Send this to your Polytomic Solutions Engineer."
  value       = module.polytomic_privatelink.resource_configuration_arn
}
