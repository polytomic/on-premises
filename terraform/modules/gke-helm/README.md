## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.polytomic](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_polytomic_cert_name"></a> [polytomic\_cert\_name](#input\_polytomic\_cert\_name) | The name of the certificate to use for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment"></a> [polytomic\_deployment](#input\_polytomic\_deployment) | The name of the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_deployment_key"></a> [polytomic\_deployment\_key](#input\_polytomic\_deployment\_key) | The key for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_id"></a> [polytomic\_google\_client\_id](#input\_polytomic\_google\_client\_id) | The google client id for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_google_client_secret"></a> [polytomic\_google\_client\_secret](#input\_polytomic\_google\_client\_secret) | The google client secret for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_image"></a> [polytomic\_image](#input\_polytomic\_image) | The image to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_image_tag"></a> [polytomic\_image\_tag](#input\_polytomic\_image\_tag) | The tag to use for the polytomic container | `any` | n/a | yes |
| <a name="input_polytomic_ip_name"></a> [polytomic\_ip\_name](#input\_polytomic\_ip\_name) | The name of the ip to use for the polytomic deployment | `any` | n/a | yes |
| <a name="input_polytomic_root_user"></a> [polytomic\_root\_user](#input\_polytomic\_root\_user) | The root user for the polytomic deployment | `string` | `"root"` | no |
| <a name="input_polytomic_url"></a> [polytomic\_url](#input\_polytomic\_url) | The url for the polytomic deployment | `any` | n/a | yes |
| <a name="input_postgres_host"></a> [postgres\_host](#input\_postgres\_host) | The host for the postgres deployment | `any` | n/a | yes |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | The password for the postgres deployment | `any` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | The host for the redis deployment | `any` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | The password for the redis deployment | `any` | n/a | yes |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | The port for the redis deployment | `number` | `6379` | no |

## Outputs

No outputs.
