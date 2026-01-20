## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.polytomic](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | The arn of the certificate to use for the polytomic deployment | `any` | n/a | yes |
| <a name="input_efs_id"></a> [efs\_id](#input\_efs\_id) | ID of the EFS volume to use for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_api_key"></a> [polytomic\_api\_key](#input\_polytomic\_api\_key) | The api key for the polytomic deployment | `string` | `""` | no |
| <a name="input_polytomic_bucket"></a> [polytomic\_bucket](#input\_polytomic\_bucket) | The operational bucket for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_bucket_region"></a> [polytomic\_bucket\_region](#input\_polytomic\_bucket\_region) | The operational bucket regoin for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment"></a> [polytomic\_deployment](#input\_polytomic\_deployment) | The name of the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment_key"></a> [polytomic\_deployment\_key](#input\_polytomic\_deployment\_key) | The key for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_id"></a> [polytomic\_google\_client\_id](#input\_polytomic\_google\_client\_id) | The google client id for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_secret"></a> [polytomic\_google\_client\_secret](#input\_polytomic\_google\_client\_secret) | The google client secret for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_image"></a> [polytomic\_image](#input\_polytomic\_image) | The image to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_image_tag"></a> [polytomic\_image\_tag](#input\_polytomic\_image\_tag) | The tag to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_root_user"></a> [polytomic\_root\_user](#input\_polytomic\_root\_user) | The root user for the polytomic deployment | `string` | `"root"` | no |
| <a name="input_polytomic_service_account_role_arn"></a> [polytomic\_service\_account\_role\_arn](#input\_polytomic\_service\_account\_role\_arn) | ARN of the role to use for the polytomic deployment service account | `any` | n/a | yes |
| <a name="input_polytomic_url"></a> [polytomic\_url](#input\_polytomic\_url) | The url for the polytomic deployment | `any` | n/a | yes |
| <a name="input_postgres_host"></a> [postgres\_host](#input\_postgres\_host) | The host for the postgres deployment | `any` | n/a | yes |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | The password for the postgres deployment | `any` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | The host for the redis deployment | `any` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | The password for the redis deployment | `string` | `""` | no |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | The port for the redis deployment | `number` | `6379` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | The subnets to use for the polytomic deployment | `string` | n/a | yes |

## Outputs

No outputs.
