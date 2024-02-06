## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_database"></a> [database](#module\_database) | terraform-aws-modules/rds/aws | 5.9.0 |
| <a name="module_database_sg"></a> [database\_sg](#module\_database\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_efs"></a> [efs](#module\_efs) | cloudposse/efs/aws | n/a |
| <a name="module_efs_sg"></a> [efs\_sg](#module\_efs\_sg) | terraform-aws-modules/security-group/aws | ~> 4.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | n/a |
| <a name="module_redis"></a> [redis](#module\_redis) | umotif-public/elasticache-redis/aws | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [random_password.redis](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_subnet.subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the bucket to create | `string` | `"polytomic-bucket"` | no |
| <a name="input_create_efs"></a> [create\_efs](#input\_create\_efs) | Whether to create an EFS instance | `bool` | `true` | no |
| <a name="input_create_postgres"></a> [create\_postgres](#input\_create\_postgres) | Whether to create a postgres instance | `bool` | `true` | no |
| <a name="input_create_redis"></a> [create\_redis](#input\_create\_redis) | Whether to create a redis instance | `bool` | `true` | no |
| <a name="input_database_allocated_storage"></a> [database\_allocated\_storage](#input\_database\_allocated\_storage) | Database allocated storage | `number` | `20` | no |
| <a name="input_database_auto_minor_version_upgrade"></a> [database\_auto\_minor\_version\_upgrade](#input\_database\_auto\_minor\_version\_upgrade) | Database auto minor version upgrade | `bool` | `false` | no |
| <a name="input_database_backup_retention"></a> [database\_backup\_retention](#input\_database\_backup\_retention) | Database backup retention | `number` | `30` | no |
| <a name="input_database_backup_window"></a> [database\_backup\_window](#input\_database\_backup\_window) | Database backup window | `string` | `"03:00-06:00"` | no |
| <a name="input_database_create_cloudwatch_log_group"></a> [database\_create\_cloudwatch\_log\_group](#input\_database\_create\_cloudwatch\_log\_group) | Database create cloudwatch log group | `bool` | `true` | no |
| <a name="input_database_create_monitoring_role"></a> [database\_create\_monitoring\_role](#input\_database\_create\_monitoring\_role) | Database create monitoring role | `bool` | `true` | no |
| <a name="input_database_deletion_protection"></a> [database\_deletion\_protection](#input\_database\_deletion\_protection) | Database deletion protection | `bool` | `true` | no |
| <a name="input_database_enabled_cloudwatch_logs_exports"></a> [database\_enabled\_cloudwatch\_logs\_exports](#input\_database\_enabled\_cloudwatch\_logs\_exports) | Database enabled cloudwatch logs exports | `list` | <pre>[<br>  "postgresql",<br>  "upgrade"<br>]</pre> | no |
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
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Desired number of nodes | `number` | `3` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type | `string` | `"t3.small"` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of nodes | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of nodes | `number` | `2` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | `"polytomic"` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs | `list` | `[]` | no |
| <a name="input_public_subnet_ids"></a> [public\_subnet\_ids](#input\_public\_subnet\_ids) | Public subnet IDs | `list` | `[]` | no |
| <a name="input_redis_at_rest_encryption_enabled"></a> [redis\_at\_rest\_encryption\_enabled](#input\_redis\_at\_rest\_encryption\_enabled) | Redis at rest encryption enabled | `string` | `"true"` | no |
| <a name="input_redis_auth_token"></a> [redis\_auth\_token](#input\_redis\_auth\_token) | Redis auth token | `string` | `""` | no |
| <a name="input_redis_cluster_size"></a> [redis\_cluster\_size](#input\_redis\_cluster\_size) | Redis cluster size | `string` | `"1"` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Redis engine version | `string` | `"6.2"` | no |
| <a name="input_redis_family"></a> [redis\_family](#input\_redis\_family) | Redis family | `string` | `"redis6.x"` | no |
| <a name="input_redis_instance_type"></a> [redis\_instance\_type](#input\_redis\_instance\_type) | Redis instance type | `string` | `"cache.t2.micro"` | no |
| <a name="input_redis_maintenance_window"></a> [redis\_maintenance\_window](#input\_redis\_maintenance\_window) | Redis maintenance window | `string` | `"mon:03:00-mon:04:00"` | no |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | Redis port | `number` | `6379` | no |
| <a name="input_redis_snapshot_retention_limit"></a> [redis\_snapshot\_retention\_limit](#input\_redis\_snapshot\_retention\_limit) | Redis snapshot retention limit | `string` | `"7"` | no |
| <a name="input_redis_snapshot_window"></a> [redis\_snapshot\_window](#input\_redis\_snapshot\_window) | Redis snapshot window | `string` | `"04:00-06:00"` | no |
| <a name="input_redis_transit_encryption_enabled"></a> [redis\_transit\_encryption\_enabled](#input\_redis\_transit\_encryption\_enabled) | Redis transit encryption enabled | `string` | `"false"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map` | `{}` | no |
| <a name="input_vpc_azs"></a> [vpc\_azs](#input\_vpc\_azs) | VPC availability zones | `list` | <pre>[<br>  "us-east-1a",<br>  "us-east-1b",<br>  "us-east-1c"<br>]</pre> | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | VPC private subnets | `list` | <pre>[<br>  "10.0.1.0/24",<br>  "10.0.2.0/24",<br>  "10.0.3.0/24"<br>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | VPC public subnets | `list` | <pre>[<br>  "10.0.101.0/24",<br>  "10.0.102.0/24",<br>  "10.0.103.0/24"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | n/a |
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Cluster ARN |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name |
| <a name="output_filesystem_id"></a> [filesystem\_id](#output\_filesystem\_id) | n/a |
| <a name="output_oidc_provider_arn"></a> [oidc\_provider\_arn](#output\_oidc\_provider\_arn) | OIDC provider ARN |
| <a name="output_postgres_host"></a> [postgres\_host](#output\_postgres\_host) | n/a |
| <a name="output_postgres_password"></a> [postgres\_password](#output\_postgres\_password) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | Subnet IDs |
| <a name="output_redis_auth_string"></a> [redis\_auth\_string](#output\_redis\_auth\_string) | n/a |
| <a name="output_redis_host"></a> [redis\_host](#output\_redis\_host) | n/a |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
