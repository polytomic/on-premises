locals {
  region  = "us-west-2"
  prefix  = "polytomic"
  vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

provider "aws" {
  region = local.region
}


module "eks" {
  source = "../../../modules/eks"

  prefix  = local.prefix
  region  = local.region
  vpc_azs = local.vpc_azs
}

