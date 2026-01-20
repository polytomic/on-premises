locals {
  region  = "us-west-2"
  prefix  = "polytomic"
  vpc_azs = ["us-west-2a", "us-west-2b", "us-west-2c"]

  # Optional: Specify exact S3 bucket name for global uniqueness or to use existing bucket
  # If not specified, defaults to "${prefix}-operations"
  # bucket_name = "my-company-polytomic-prod"
}

provider "aws" {
  region = local.region
}


module "eks" {
  source = "github.com/polytomic/on-premises/terraform/modules/eks"

  prefix  = local.prefix
  region  = local.region
  vpc_azs = local.vpc_azs

  # Uncomment to specify explicit bucket name (otherwise uses "${prefix}-operations")
  # bucket_name = local.bucket_name
}

