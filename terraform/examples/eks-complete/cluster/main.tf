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
  source = "../../../modules/eks"

  prefix  = local.prefix
  region  = local.region
  vpc_azs = local.vpc_azs

  # Uncomment to specify explicit bucket name (otherwise uses "${prefix}-operations")
  # bucket_name = local.bucket_name

  # Optional: Grant additional IAM principals access to the cluster
  # By default, only the IAM principal that creates the cluster (the one running Terraform) has access.
  # Uncomment and modify to grant access to additional users/roles (e.g., your root user, DevOps team members)
  #
  # access_entries = {
  #   # Example: Grant cluster admin access to root user
  #   root_user = {
  #     principal_arn = "arn:aws:iam::123456789012:root"
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  #   # Example: Grant a specific IAM user admin access
  #   devops_user = {
  #     principal_arn = "arn:aws:iam::123456789012:user/devops-admin"
  #     policy_associations = {
  #       admin = {
  #         policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #         access_scope = {
  #           type = "cluster"
  #         }
  #       }
  #     }
  #   }
  # }
}

