## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vector_role"></a> [vector\_role](#module\_vector\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.vector_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.polytomic](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_iam_policy_document.vector_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The arn of the certificate to use for the polytomic deployment. If not provided, the ALB will listen on HTTP (port 80) only. | `string` | `""` | no |
| <a name="input_chart_path"></a> [chart\_path](#input\_chart\_path) | Path to local Helm chart. Only used when chart\_repository is empty. Defaults to relative path to chart in this repository. | `string` | `""` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | The Helm chart repository URL. Leave empty to use local chart. | `string` | `"https://charts.polytomic.com"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of the Polytomic Helm chart to install. Only used when chart\_repository is set. | `string` | `""` | no |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | ID of the EFS volume to use for the polytomic deployment | `any` | n/a | yes |
| <a name="input_execution_log_bucket_arn"></a> [execution\_log\_bucket\_arn](#input\_execution\_log\_bucket\_arn) | ARN of the S3 bucket for execution logs. Used for Vector DaemonSet IAM permissions. | `string` | `""` | no |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | OIDC provider ARN for IRSA (IAM Roles for Service Accounts). Required for Vector DaemonSet IAM role. | `string` | `""` | no |
| <a name="input_polytomic_api_key"></a> [polytomic\_api\_key](#input\_polytomic\_api\_key) | The api key for the polytomic deployment | `string` | `""` | no |
| <a name="input_polytomic_bucket"></a> [polytomic\_bucket](#input\_polytomic\_bucket) | The operational bucket for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_bucket_region"></a> [polytomic\_bucket\_region](#input\_polytomic\_bucket\_region) | The operational bucket regoin for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment"></a> [polytomic\_deployment](#input\_polytomic\_deployment) | The name of the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment_key"></a> [polytomic\_deployment\_key](#input\_polytomic\_deployment\_key) | The key for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_id"></a> [polytomic\_google\_client\_id](#input\_polytomic\_google\_client\_id) | The google client id for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_secret"></a> [polytomic\_google\_client\_secret](#input\_polytomic\_google\_client\_secret) | The google client secret for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_image"></a> [polytomic\_image](#input\_polytomic\_image) | The image to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_image_tag"></a> [polytomic\_image\_tag](#input\_polytomic\_image\_tag) | The tag to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_logger_image"></a> [polytomic\_logger\_image](#input\_polytomic\_logger\_image) | Docker image repository for Vector DaemonSet with ptconf for secret decryption | `string` | `"568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-vector"` | no |
| <a name="input_polytomic_logger_image_tag"></a> [polytomic\_logger\_image\_tag](#input\_polytomic\_logger\_image\_tag) | Tag for the Vector DaemonSet image. Defaults to polytomic\_image\_tag when not set. | `string` | `null` | no |
| <a name="input_polytomic_managed_logs"></a> [polytomic\_managed\_logs](#input\_polytomic\_managed\_logs) | Enable Datadog log forwarding for both embedded Vector and DaemonSet. Matches ECS module variable. | `bool` | `false` | no |
| <a name="input_polytomic_root_user"></a> [polytomic\_root\_user](#input\_polytomic\_root\_user) | The root user for the polytomic deployment | `string` | `"root"` | no |
| <a name="input_polytomic_service_account_role_arn"></a> [polytomic\_service\_account\_role\_arn](#input\_polytomic\_service\_account\_role\_arn) | ARN of the role to use for the polytomic deployment service account | `any` | n/a | yes |
| <a name="input_polytomic_url"></a> [polytomic\_url](#input\_polytomic\_url) | The url for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_use_logger"></a> [polytomic\_use\_logger](#input\_polytomic\_use\_logger) | Deploy Vector DaemonSet for stdout/stderr log collection. Disable to reduce costs in dev environments or if using alternative log collection. Matches ECS module variable. | `bool` | `true` | no |
| <a name="input_postgres_host"></a> [postgres\_host](#input\_postgres\_host) | The host for the postgres deployment | `any` | n/a | yes |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | The password for the postgres deployment | `any` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | The host for the redis deployment | `any` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | The password for the redis deployment | `string` | `""` | no |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | The port for the redis deployment | `number` | `6379` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnets to use for the polytomic deployment | `string` | n/a | yes |

## Outputs

No outputs.
