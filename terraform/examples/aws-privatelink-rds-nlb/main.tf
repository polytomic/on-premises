// Minimal working example of the aws-privatelink-rds-nlb module.
//
// Assumes you already have an RDS instance and know its VPC, subnets, and
// security group. Replace the `data` lookups below with your own references
// if you are composing this with the rest of your Terraform.

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
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
  source = "../../modules/aws-privatelink-rds-nlb"

  vpc_id     = data.aws_vpc.existing.id
  subnet_ids = data.aws_subnets.private.ids

  rds_host              = data.aws_db_instance.existing.address
  rds_port              = data.aws_db_instance.existing.port
  rds_security_group_id = data.aws_db_instance.existing.vpc_security_groups[0]

  polytomic_aws_account_id = var.polytomic_aws_account_id
}

output "service_name" {
  description = "Send this to your Polytomic Solutions Engineer."
  value       = module.polytomic_privatelink.service_name
}
