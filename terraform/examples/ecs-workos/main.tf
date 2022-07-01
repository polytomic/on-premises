provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "github.com/polytomic/on-premises/terraform/modules/ecs"

  prefix = "workos"
  region = "us-east-1"


  tags = {
    Owner       = "polytomic"
    Environment = "staging"
    Billing     = "R/D"
  }

  ####### Polytomic settings #######
  polytomic_image = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:rel2022.06.30.01"

  polytomic_root_user      = "user@example.com"
  polytomic_deployment     = "DEPLYOMENT"
  polytomic_deployment_key = "DEPLYOMENT_KEY"

  # Name of first Polytomic workspace
  polytomic_workspace_name = "polytomic-workspace"
  # Domain for SSO users of first Polytomic workspace; ie, example.com.
  polytomic_workos_org_id = "WORKOS_ORG_ID"
  # orkOS organization ID for workspace SSO
  polytomic_sso_domain = "WORKOS_SSO_DOMAIN"
  # WorkOS client ID
  polytomic_workos_client_id = "WORKOS_CLIENT_ID"
  # WorkOS API key
  polytomic_workos_api_key = "WORKOS_API_KEY"

  polytomic_bootstrap = true


  ####### VPC settings #######

  vpc_cidr            = "10.0.0.0/16"
  vpc_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  ####### Redis settings #######
  redis_instance_type = "cache.r6g.large"

  ####### Postgres settings #######
  database_instance_class = "db.t3.medium"

}
