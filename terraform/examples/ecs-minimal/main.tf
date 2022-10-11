provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "../../modules/ecs"

  prefix = "polytomic-2"
  region = "us-east-1"

  ####### Polytomic settings #######
  polytomic_image = "005734951936.dkr.ecr.us-east-1.amazonaws.com/jake-on-prem:execution-logs"

  polytomic_root_user      = "user@example.com"
  polytomic_deployment     = "DEPLOYMENT"
  polytomic_deployment_key = "DEPLOYMENT_KEY"

  polytomic_google_client_id     = "GOOGLE_ID"
  polytomic_google_client_secret = "GOOGLE_SECRET"

}
