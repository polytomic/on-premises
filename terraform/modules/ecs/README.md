# Polytomic On ECS Fargate

This module will all the necessary configuration to run a Polytomic On ECS Fargate.
Using the architecture outlined in the image below.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

# Architecture
![arch](./aws_arch.png)

# Examples

Complete
```hcl
provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "github.com/polytomic/on-premises/terraform/modules/ecs"

  prefix = "polytomic"
  tags = {
    Owner       = "polytomic"
    Environment = "staging"
    Billing     = "R/D"
  }

  region = "us-east-1"

  ####### Polytomic settings #######
  polytomic_image = "568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest"

  polytomic_root_user          = "user@example.com"
  polytomic_deployment         = "DEPLOYMENT"
  polytomic_deployment_key     = "DEPLOYMENT_KEY"
  polytomic_deployment_api_key = "DEPLOYMENT_API_KEY"

  polytomic_google_client_id     = "GOOGLE_ID"
  polytomic_google_client_secret = "GOOGLE_SECRET"
  polytomic_url                  = ""

  polytomic_single_player       = false
  polytomic_bootstrap           = true
  polytomic_record_log_disabled = false

  # valid values are debug, info, warn, error; the default is info
  polytomic_log_level = "info"

  # enable periodically writing stats to S3
  enable_stats = true


  alert_emails = ["user@example.com"]
  aws_profile  = "default"

  enable_monitoring = true

  extra_environment = {
    FOO = "BAR"
  }


  ####### VPC settings #######
  #
  # Use this to set the VPC ID to use for the VPC.
  # If not set, the VPC will be created.
  # vpc_id = "vpc-123456789"
  vpc_id             = ""
  private_subnet_ids = []
  public_subnet_ids  = []
  #
  # New VPC settings
  vpc_cidr            = "10.0.0.0/16"
  vpc_azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpc_public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]


  ####### ECS settings #######
  #
  # Use this if you want to use an existing ECS cluster.
  # If not set, a new ECS cluster will be created.
  # ecs_cluster_name = "my-ecs-cluster"
  ecs_cluster_name = ""


  ####### Redis settings #######
  #
  # Use this if you already have a Redis endpoint set up.
  # If left blank, we'll create a new Redis instance for you using the settings below.
  # redis_endpoint = redis://:password@host:6379/"
  redis_endpoint = ""
  #
  # New Redis instance settings
  redis_cluster_size = 1

  redis_port           = 6379
  redis_instance_type  = "cache.t2.micro"
  redis_engine_version = "6.2"
  redis_family         = "redis6.x"

  redis_at_rest_encryption_enabled = true
  redis_transit_encryption_enabled = true


  redis_maintenance_window       = "mon:03:00-mon:04:00"
  redis_snapshot_window          = "04:00-06:00"
  redis_snapshot_retention_limit = 7

  ####### Database settings #######
  #
  # Use this if you already have a database endpoint set up.
  # If left blank, we'll create a new database instance for you using the settings below.
  # database_endpoint = "postgres://user:password@host:port/database"
  database_endpoint = ""
  #
  # New database instance settings
  database_username             = "polytomic"
  database_name                 = "polytomic"
  database_port                 = 5432
  database_engine               = "postgres"
  database_engine_version       = "14.1"
  database_family               = "postgres14"
  database_major_engine_version = "14"
  database_instance_class       = "db.t3.small"

  database_multi_az              = true
  database_allocated_storage     = 20
  database_max_allocated_storage = 100
  database_backup_retention      = 30
  database_maintenance_window    = "Mon:00:00-Mon:03:00"
  database_backup_window         = "03:00-06:00"
  database_skip_final_snapshot   = false
  database_deletion_protection   = false


  database_enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  database_create_cloudwatch_log_group           = false
  database_performance_insights_enabled          = true
  database_performance_insights_retention_period = 7

  database_create_monitoring_role = true
  database_monitoring_interval    = 60
  database_monitoring_role_name   = "monitoring-role"
}
```


Minimal
```hcl
provider "aws" {
  region = "us-east-1"
}

module "polytomic-ecs" {
  source = "github.com/polytomic/on-premises//terraform/modules/ecs?ref=v1.0.0"

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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.22.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Resources

| Name | Type |
|------|------|
| [aws_alb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_target_group.polytomic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_cloudwatch_event_rule.oom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_ecs_service.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_service.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.stats_reporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecs_task_definition.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.polytomic_ecs_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.polytomic_ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.polytomic_stats_reporter_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.polytomic_ecs_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.polytomic_ecs_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.polytomic_stats_reporter_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_key.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_sns_topic.alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.oom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.alert_emails](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [null_resource.boostrap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.preflight](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.deployment_api_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.redis](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_cluster) | data source |
| [aws_iam_policy_document.ecs_tasks_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.events_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.oom_topic_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.polytomic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.polytomic_stats_reporter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.polytomic_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_database"></a> [database](#module\_database) | terraform-aws-modules/rds/aws | 5.9.0 |
| <a name="module_database_sg"></a> [database\_sg](#module\_database\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | terraform-aws-modules/ecs/aws | <5.0.0 |
| <a name="module_ecs-alerts-worker"></a> [ecs-alerts-worker](#module\_ecs-alerts-worker) | ../monitoring/ecs-alerts | n/a |
| <a name="module_ecs_log_groups"></a> [ecs\_log\_groups](#module\_ecs\_log\_groups) | terraform-aws-modules/cloudwatch/aws//modules/log-group | ~> 3.0 |
| <a name="module_efs"></a> [efs](#module\_efs) | cloudposse/efs/aws | ~> 0.35.0 |
| <a name="module_efs_sg"></a> [efs\_sg](#module\_efs\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_elasticache-alerts"></a> [elasticache-alerts](#module\_elasticache-alerts) | ../monitoring/elasticache-alerts | n/a |
| <a name="module_fargate_sg"></a> [fargate\_sg](#module\_fargate\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_lb_sg"></a> [lb\_sg](#module\_lb\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | terraform-aws-modules/cloudwatch/aws//modules/log-group | ~> 3.0 |
| <a name="module_rds-alerts"></a> [rds-alerts](#module\_rds-alerts) | ../monitoring/rds-alerts | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | umotif-public/elasticache-redis/aws | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | n/a |
| <a name="module_scheduled_task"></a> [scheduled\_task](#module\_scheduled\_task) | cn-terraform/ecs-fargate-scheduled-task/aws | 1.0.22 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | <5.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ecs_security_groups"></a> [additional\_ecs\_security\_groups](#input\_additional\_ecs\_security\_groups) | ECS security group ids | `list` | `[]` | no |
| <a name="input_alert_emails"></a> [alert\_emails](#input\_alert\_emails) | Email addresses to send alerts to | `list(string)` | `[]` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS profile to use | `string` | `"default"` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | Bucket prefix | `string` | `""` | no |
| <a name="input_database_allocated_storage"></a> [database\_allocated\_storage](#input\_database\_allocated\_storage) | Database allocated storage | `number` | `20` | no |
| <a name="input_database_auto_minor_version_upgrade"></a> [database\_auto\_minor\_version\_upgrade](#input\_database\_auto\_minor\_version\_upgrade) | Database auto minor version upgrade | `bool` | `false` | no |
| <a name="input_database_backup_retention"></a> [database\_backup\_retention](#input\_database\_backup\_retention) | Database backup retention | `number` | `30` | no |
| <a name="input_database_backup_window"></a> [database\_backup\_window](#input\_database\_backup\_window) | Database backup window | `string` | `"03:00-06:00"` | no |
| <a name="input_database_create_cloudwatch_log_group"></a> [database\_create\_cloudwatch\_log\_group](#input\_database\_create\_cloudwatch\_log\_group) | Database create cloudwatch log group | `bool` | `true` | no |
| <a name="input_database_create_monitoring_role"></a> [database\_create\_monitoring\_role](#input\_database\_create\_monitoring\_role) | Database create monitoring role | `bool` | `true` | no |
| <a name="input_database_deletion_protection"></a> [database\_deletion\_protection](#input\_database\_deletion\_protection) | Database deletion protection | `bool` | `true` | no |
| <a name="input_database_enabled_cloudwatch_logs_exports"></a> [database\_enabled\_cloudwatch\_logs\_exports](#input\_database\_enabled\_cloudwatch\_logs\_exports) | Database enabled cloudwatch logs exports | `list` | <pre>[<br>  "postgresql",<br>  "upgrade"<br>]</pre> | no |
| <a name="input_database_endpoint"></a> [database\_endpoint](#input\_database\_endpoint) | Database Endpoint | `string` | `""` | no |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | Database engine | `string` | `"postgres"` | no |
| <a name="input_database_engine_version"></a> [database\_engine\_version](#input\_database\_engine\_version) | Database engine version | `string` | `"14.7"` | no |
| <a name="input_database_family"></a> [database\_family](#input\_database\_family) | Database family | `string` | `"postgres14"` | no |
| <a name="input_database_instance_class"></a> [database\_instance\_class](#input\_database\_instance\_class) | Database instance class | `string` | `"db.t3.small"` | no |
| <a name="input_database_maintenance_window"></a> [database\_maintenance\_window](#input\_database\_maintenance\_window) | Database maintenance window | `string` | `"Mon:00:00-Mon:03:00"` | no |
| <a name="input_database_major_engine_version"></a> [database\_major\_engine\_version](#input\_database\_major\_engine\_version) | Database major engine version | `string` | `"14"` | no |
| <a name="input_database_max_allocated_storage"></a> [database\_max\_allocated\_storage](#input\_database\_max\_allocated\_storage) | Database max allocated storage | `number` | `100` | no |
| <a name="input_database_monitoring_interval"></a> [database\_monitoring\_interval](#input\_database\_monitoring\_interval) | Database monitoring interval | `number` | `60` | no |
| <a name="input_database_monitoring_role_name"></a> [database\_monitoring\_role\_name](#input\_database\_monitoring\_role\_name) | Database monitoring role name | `string` | `"polytomic-monitoring-role"` | no |
| <a name="input_database_multi_az"></a> [database\_multi\_az](#input\_database\_multi\_az) | Multi-AZ database | `bool` | `true` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Database Name | `string` | `"polytomic"` | no |
| <a name="input_database_performance_insights_enabled"></a> [database\_performance\_insights\_enabled](#input\_database\_performance\_insights\_enabled) | Database performance insights enabled | `bool` | `true` | no |
| <a name="input_database_performance_insights_retention_period"></a> [database\_performance\_insights\_retention\_period](#input\_database\_performance\_insights\_retention\_period) | Database performance insights retention period | `number` | `7` | no |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | Database port | `number` | `5432` | no |
| <a name="input_database_skip_final_snapshot"></a> [database\_skip\_final\_snapshot](#input\_database\_skip\_final\_snapshot) | Database skip final snapshot | `bool` | `false` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Database username | `string` | `"polytomic"` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | ECS cluster name | `string` | `""` | no |
| <a name="input_ecs_enable_container_insights"></a> [ecs\_enable\_container\_insights](#input\_ecs\_enable\_container\_insights) | ECS enable container insights | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | enable automatic monitoring | `bool` | `false` | no |
| <a name="input_enable_stats"></a> [enable\_stats](#input\_enable\_stats) | enable automatic stats reporting | `bool` | `false` | no |
| <a name="input_extra_environment"></a> [extra\_environment](#input\_extra\_environment) | Extra environment variables to pass to the containers | `map(string)` | `{}` | no |
| <a name="input_load_balancer_internal"></a> [load\_balancer\_internal](#input\_load\_balancer\_internal) | use internal load balancer | `bool` | `false` | no |
| <a name="input_load_balancer_redirect_https"></a> [load\_balancer\_redirect\_https](#input\_load\_balancer\_redirect\_https) | enable https listener on load balancer | `bool` | `false` | no |
| <a name="input_load_balancer_security_groups"></a> [load\_balancer\_security\_groups](#input\_load\_balancer\_security\_groups) | security groups for load balancer | `list(string)` | `[]` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Cloudwatch log retention days | `number` | `120` | no |
| <a name="input_polyotmic_efs_caching"></a> [polyotmic\_efs\_caching](#input\_polyotmic\_efs\_caching) | Enable EFS caching | `bool` | `false` | no |
| <a name="input_polytomic_bootstrap"></a> [polytomic\_bootstrap](#input\_polytomic\_bootstrap) | Whether to bootstrap Polytomic | `bool` | `false` | no |
| <a name="input_polytomic_data_path"></a> [polytomic\_data\_path](#input\_polytomic\_data\_path) | Filesystem path to local data cache | `string` | `"/var/polytomic"` | no |
| <a name="input_polytomic_dd_agent_image"></a> [polytomic\_dd\_agent\_image](#input\_polytomic\_dd\_agent\_image) | Docker image to use for the Datadog agent | `string` | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-dd-agent:latest"` | no |
| <a name="input_polytomic_deployment"></a> [polytomic\_deployment](#input\_polytomic\_deployment) | A unique identifier for your on premises deploy, provided by Polytomic | `string` | `""` | no |
| <a name="input_polytomic_deployment_api_key"></a> [polytomic\_deployment\_api\_key](#input\_polytomic\_deployment\_api\_key) | API key used to authenticate with the Polytomic management API | `string` | `""` | no |
| <a name="input_polytomic_deployment_key"></a> [polytomic\_deployment\_key](#input\_polytomic\_deployment\_key) | The license key for your deployment, provided by Polytomic | `string` | `""` | no |
| <a name="input_polytomic_deployment_links"></a> [polytomic\_deployment\_links](#input\_polytomic\_deployment\_links) | Additional links to display in the Polytomic navigation | <pre>list(object({<br>    name = string<br>    url  = string<br>  }))</pre> | `[]` | no |
| <a name="input_polytomic_enabled_backends"></a> [polytomic\_enabled\_backends](#input\_polytomic\_enabled\_backends) | List of backends to enable | `list` | `[]` | no |
| <a name="input_polytomic_ga_measurement_id"></a> [polytomic\_ga\_measurement\_id](#input\_polytomic\_ga\_measurement\_id) | Google Analytics Measurement ID | `string` | `""` | no |
| <a name="input_polytomic_google_client_id"></a> [polytomic\_google\_client\_id](#input\_polytomic\_google\_client\_id) | Google OAuth Client ID, obtained by creating a OAuth 2.0 Client ID | `string` | `""` | no |
| <a name="input_polytomic_google_client_secret"></a> [polytomic\_google\_client\_secret](#input\_polytomic\_google\_client\_secret) | Google OAuth Client Secret, obtained by creating a OAuth 2.0 Client ID | `string` | `""` | no |
| <a name="input_polytomic_image"></a> [polytomic\_image](#input\_polytomic\_image) | Docker image to use for the Polytomic ECS cluster | `string` | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem:latest"` | no |
| <a name="input_polytomic_legacy_config"></a> [polytomic\_legacy\_config](#input\_polytomic\_legacy\_config) | Use legacy configuration | `bool` | `false` | no |
| <a name="input_polytomic_log_level"></a> [polytomic\_log\_level](#input\_polytomic\_log\_level) | The log level to use for Polytomic | `string` | `"info"` | no |
| <a name="input_polytomic_logger_image"></a> [polytomic\_logger\_image](#input\_polytomic\_logger\_image) | Docker image to use for the Polytomic log aggregator | `string` | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-vector:latest"` | no |
| <a name="input_polytomic_managed_logs"></a> [polytomic\_managed\_logs](#input\_polytomic\_managed\_logs) | Use managed logs | `bool` | `false` | no |
| <a name="input_polytomic_mssql_tx_isolation"></a> [polytomic\_mssql\_tx\_isolation](#input\_polytomic\_mssql\_tx\_isolation) | Transaction isolation level for MSSQL connections | `string` | `""` | no |
| <a name="input_polytomic_port"></a> [polytomic\_port](#input\_polytomic\_port) | Port on which Polytomic is listening | `string` | `"80"` | no |
| <a name="input_polytomic_preflight_check"></a> [polytomic\_preflight\_check](#input\_polytomic\_preflight\_check) | Whether to run a preflight check | `bool` | `false` | no |
| <a name="input_polytomic_query_runner_exclude_dbs"></a> [polytomic\_query\_runner\_exclude\_dbs](#input\_polytomic\_query\_runner\_exclude\_dbs) | List of databases to exclude from query runner | `list` | `[]` | no |
| <a name="input_polytomic_query_worker_count"></a> [polytomic\_query\_worker\_count](#input\_polytomic\_query\_worker\_count) | Number of query workers to use | `number` | `20` | no |
| <a name="input_polytomic_record_log_disabled"></a> [polytomic\_record\_log\_disabled](#input\_polytomic\_record\_log\_disabled) | Globally disable record logging for this deployment | `bool` | `false` | no |
| <a name="input_polytomic_resource_scheduler_cpu"></a> [polytomic\_resource\_scheduler\_cpu](#input\_polytomic\_resource\_scheduler\_cpu) | CPU units for the scheduler container | `number` | `1024` | no |
| <a name="input_polytomic_resource_scheduler_memory"></a> [polytomic\_resource\_scheduler\_memory](#input\_polytomic\_resource\_scheduler\_memory) | Memory units for the scheduler container | `number` | `2048` | no |
| <a name="input_polytomic_resource_sync_count"></a> [polytomic\_resource\_sync\_count](#input\_polytomic\_resource\_sync\_count) | Number of sync containers to run | `number` | `2` | no |
| <a name="input_polytomic_resource_sync_cpu"></a> [polytomic\_resource\_sync\_cpu](#input\_polytomic\_resource\_sync\_cpu) | CPU units for the sync container | `number` | `4096` | no |
| <a name="input_polytomic_resource_sync_memory"></a> [polytomic\_resource\_sync\_memory](#input\_polytomic\_resource\_sync\_memory) | Memory units for the sync container | `number` | `8192` | no |
| <a name="input_polytomic_resource_sync_storage"></a> [polytomic\_resource\_sync\_storage](#input\_polytomic\_resource\_sync\_storage) | Ephemeral storage for the sync container | `number` | `21` | no |
| <a name="input_polytomic_resource_web_cpu"></a> [polytomic\_resource\_web\_cpu](#input\_polytomic\_resource\_web\_cpu) | CPU units for the web container | `number` | `2048` | no |
| <a name="input_polytomic_resource_web_memory"></a> [polytomic\_resource\_web\_memory](#input\_polytomic\_resource\_web\_memory) | Memory units for the web container | `number` | `4096` | no |
| <a name="input_polytomic_resource_worker_cpu"></a> [polytomic\_resource\_worker\_cpu](#input\_polytomic\_resource\_worker\_cpu) | CPU units for the worker container | `number` | `2048` | no |
| <a name="input_polytomic_resource_worker_memory"></a> [polytomic\_resource\_worker\_memory](#input\_polytomic\_resource\_worker\_memory) | Memory units for the worker container | `number` | `4096` | no |
| <a name="input_polytomic_root_user"></a> [polytomic\_root\_user](#input\_polytomic\_root\_user) | The email address to use when starting for the first time; this user will be able to add additional users and configure Polytomic | `string` | `""` | no |
| <a name="input_polytomic_single_player"></a> [polytomic\_single\_player](#input\_polytomic\_single\_player) | Whether to use the single player mode | `bool` | `false` | no |
| <a name="input_polytomic_sso_domain"></a> [polytomic\_sso\_domain](#input\_polytomic\_sso\_domain) | Domain for SSO users of first Polytomic workspace; ie, example.com. | `string` | `""` | no |
| <a name="input_polytomic_sync_logging_enabled"></a> [polytomic\_sync\_logging\_enabled](#input\_polytomic\_sync\_logging\_enabled) | Record execution logs for syncs performed via Polytomic | `bool` | `true` | no |
| <a name="input_polytomic_tx_buffer_size"></a> [polytomic\_tx\_buffer\_size](#input\_polytomic\_tx\_buffer\_size) | Transaction buffer size for datalite cache | `number` | `50000` | no |
| <a name="input_polytomic_url"></a> [polytomic\_url](#input\_polytomic\_url) | Base URL for accessing Polytomic. This will be used when redirecting back from Google and other integrations after authenticating with OAuth. | `string` | `""` | no |
| <a name="input_polytomic_use_dd_agent"></a> [polytomic\_use\_dd\_agent](#input\_polytomic\_use\_dd\_agent) | Use Datadog agent | `bool` | `false` | no |
| <a name="input_polytomic_use_logger"></a> [polytomic\_use\_logger](#input\_polytomic\_use\_logger) | Use polytomic log aggregator | `bool` | `true` | no |
| <a name="input_polytomic_workos_api_key"></a> [polytomic\_workos\_api\_key](#input\_polytomic\_workos\_api\_key) | The API key for the WorkOS account to use for Polytomic | `string` | `""` | no |
| <a name="input_polytomic_workos_client_id"></a> [polytomic\_workos\_client\_id](#input\_polytomic\_workos\_client\_id) | The WorkOS client ID | `string` | `""` | no |
| <a name="input_polytomic_workos_org_id"></a> [polytomic\_workos\_org\_id](#input\_polytomic\_workos\_org\_id) | WorkOS organization ID for workspace SSO | `string` | `""` | no |
| <a name="input_polytomic_workspace_name"></a> [polytomic\_workspace\_name](#input\_polytomic\_workspace\_name) | Name of first Polytomic workspace | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | n/a | `any` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet IDs | `list` | `[]` | no |
| <a name="input_redis_at_rest_encryption_enabled"></a> [redis\_at\_rest\_encryption\_enabled](#input\_redis\_at\_rest\_encryption\_enabled) | Redis at rest encryption enabled | `string` | `"true"` | no |
| <a name="input_redis_auth_token"></a> [redis\_auth\_token](#input\_redis\_auth\_token) | Redis auth token | `string` | `""` | no |
| <a name="input_redis_cluster_size"></a> [redis\_cluster\_size](#input\_redis\_cluster\_size) | Redis cluster size | `string` | `"1"` | no |
| <a name="input_redis_endpoint"></a> [redis\_endpoint](#input\_redis\_endpoint) | Redis endpoint | `string` | `""` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Redis engine version | `string` | `"6.2"` | no |
| <a name="input_redis_family"></a> [redis\_family](#input\_redis\_family) | Redis family | `string` | `"redis6.x"` | no |
| <a name="input_redis_instance_type"></a> [redis\_instance\_type](#input\_redis\_instance\_type) | Redis instance type | `string` | `"cache.t2.micro"` | no |
| <a name="input_redis_maintenance_window"></a> [redis\_maintenance\_window](#input\_redis\_maintenance\_window) | Redis maintenance window | `string` | `"mon:03:00-mon:04:00"` | no |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | Redis port | `number` | `6379` | no |
| <a name="input_redis_snapshot_retention_limit"></a> [redis\_snapshot\_retention\_limit](#input\_redis\_snapshot\_retention\_limit) | Redis snapshot retention limit | `string` | `"7"` | no |
| <a name="input_redis_snapshot_window"></a> [redis\_snapshot\_window](#input\_redis\_snapshot\_window) | Redis snapshot window | `string` | `"04:00-06:00"` | no |
| <a name="input_redis_transit_encryption_enabled"></a> [redis\_transit\_encryption\_enabled](#input\_redis\_transit\_encryption\_enabled) | Redis transit encryption enabled | `string` | `"true"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to use | `string` | `"us-east-1"` | no |
| <a name="input_stats_cron"></a> [stats\_cron](#input\_stats\_cron) | Stats cron | `string` | `"cron(0 0 * * ? *)"` | no |
| <a name="input_stats_format"></a> [stats\_format](#input\_stats\_format) | Output format for stats reporter | `string` | `"json"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_task_tags"></a> [task\_tags](#input\_task\_tags) | A map of tags to add to application-launched tasks | `map(string)` | `{}` | no |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | VPC availability zones | `list` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | VPC private subnets | `list` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC public subnets | `list` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24",<br>  "10.0.103.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | n/a |
| <a name="output_deploy_api_key"></a> [deploy\_api\_key](#output\_deploy\_api\_key) | API key used to authenticate with the Polytomic management API. |
| <a name="output_loadbalancer_arn"></a> [loadbalancer\_arn](#output\_loadbalancer\_arn) | n/a |
| <a name="output_loadbalancer_dns_name"></a> [loadbalancer\_dns\_name](#output\_loadbalancer\_dns\_name) | n/a |
| <a name="output_loadbalancer_zone_id"></a> [loadbalancer\_zone\_id](#output\_loadbalancer\_zone\_id) | n/a |
| <a name="output_override_sgs"></a> [override\_sgs](#output\_override\_sgs) | n/a |
| <a name="output_override_subnets"></a> [override\_subnets](#output\_override\_subnets) | n/a |
| <a name="output_override_task_definition"></a> [override\_task\_definition](#output\_override\_task\_definition) | n/a |
| <a name="output_target_group_arn"></a> [target\_group\_arn](#output\_target\_group\_arn) | n/a |
