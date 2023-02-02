provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "github.com/polytomic/on-premises/terraform/modules/ecs"

  prefix = "polytomic-2"
  region = "us-east-1"

  ####### Polytomic settings #######
  polytomic_image = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest"

  polytomic_root_user      = "user@example.com"
  polytomic_deployment     = "DEPLOYMENT"
  polytomic_deployment_key = "DEPLOYMENT_KEY"

  polytomic_google_client_id     = "GOOGLE_ID"
  polytomic_google_client_secret = "GOOGLE_SECRET"

  # Existing VPC settings
  vpc_id             = "vpc-01462540afd033c70"
  private_subnet_ids = ["subnet-079bc99ddd9bb9a13", "subnet-0658ae11362c98ded", "subnet-0938f40991b78bdb7"]
  public_subnet_ids  = ["subnet-0ae40b059545091b3", "subnet-09d50ce0d2844f304", "subnet-0f506582cacf64e98"]


  # Existing ECS cluster
  ecs_cluster_name = "polytomic-cluster"

  # Existing RDS settings
  database_endpoint = "postgres://user:password@host:port/database"

  # Existing redis settings
  redis_endpoint = "rediss://:password@host:port"

}
