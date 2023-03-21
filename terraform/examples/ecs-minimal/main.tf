provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "github.com/polytomic/on-premises/terraform/modules/ecs"

  prefix = "polytomic"
  region = "us-east-1"

  ####### Polytomic settings #######
  polytomic_image = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest"

  polytomic_root_user      = "user@example.com"
  polytomic_deployment     = "DEPLOYMENT"
  polytomic_deployment_key = "DEPLOYMENT_KEY"

  polytomic_google_client_id     = "GOOGLE_ID"
  polytomic_google_client_secret = "GOOGLE_SECRET"

}
