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
| <a name="input_chart_path"></a> [chart\_path](#input\_chart\_path) | Path to local Helm chart. Only used when chart\_repository is empty. Defaults to relative path to chart in this repository. | `string` | `""` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | The Helm chart repository URL. Leave empty to use local chart. | `string` | `"https://charts.polytomic.com"` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | The version of the Polytomic Helm chart to install. Only used when chart\_repository is set. | `string` | `""` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the PostgreSQL database to connect to | `string` | `"polytomic"` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Username for the PostgreSQL database connection | `string` | `"polytomic"` | no |
| <a name="input_extra_helm_values"></a> [extra\_helm\_values](#input\_extra\_helm\_values) | Additional Helm values in raw YAML format. Merged after the module's default values, so these take precedence. | `string` | `""` | no |
| <a name="input_force_update"></a> [force\_update](#input\_force\_update) | Force Helm to update the release even if no changes are detected. | `bool` | `false` | no |
| <a name="input_image_registry"></a> [image\_registry](#input\_image\_registry) | Container image registry for all Polytomic images (e.g., us.gcr.io/polytomic-container-distro or us-docker.pkg.dev/project/repo). Equivalent to imageRegistry in the Helm chart. | `string` | n/a | yes |
| <a name="input_polytomic_api_key"></a> [polytomic\_api\_key](#input\_polytomic\_api\_key) | The api key for the polytomic deployment | `string` | `""` | no |
| <a name="input_polytomic_bucket"></a> [polytomic\_bucket](#input\_polytomic\_bucket) | The GCS bucket name for operational data | `string` | n/a | yes |
| <a name="input_polytomic_cert_name"></a> [polytomic\_cert\_name](#input\_polytomic\_cert\_name) | The name of the GCP managed SSL certificate for ingress | `string` | n/a | yes |
| <a name="input_polytomic_dd_agent_image"></a> [polytomic\_dd\_agent\_image](#input\_polytomic\_dd\_agent\_image) | Image name for the Datadog Agent DaemonSet. | `string` | `"polytomic-dd-agent"` | no |
| <a name="input_polytomic_dd_agent_image_tag"></a> [polytomic\_dd\_agent\_image\_tag](#input\_polytomic\_dd\_agent\_image\_tag) | Tag for the Datadog Agent DaemonSet image. Defaults to polytomic\_image\_tag when not set. | `string` | `null` | no |
| <a name="input_polytomic_deployment"></a> [polytomic\_deployment](#input\_polytomic\_deployment) | The name of the polytomic deployment | `string` | n/a | yes |
| <a name="input_polytomic_deployment_key"></a> [polytomic\_deployment\_key](#input\_polytomic\_deployment\_key) | The key for the polytomic deployment | `string` | n/a | yes |
| <a name="input_polytomic_google_client_id"></a> [polytomic\_google\_client\_id](#input\_polytomic\_google\_client\_id) | Google OAuth client ID | `string` | `""` | no |
| <a name="input_polytomic_google_client_secret"></a> [polytomic\_google\_client\_secret](#input\_polytomic\_google\_client\_secret) | Google OAuth client secret | `string` | `""` | no |
| <a name="input_polytomic_image"></a> [polytomic\_image](#input\_polytomic\_image) | Image name for the Polytomic container (without registry prefix). Combined with image\_registry to form the full image reference. | `string` | `"polytomic-onprem"` | no |
| <a name="input_polytomic_image_tag"></a> [polytomic\_image\_tag](#input\_polytomic\_image\_tag) | The tag to use for the polytomic container | `string` | n/a | yes |
| <a name="input_polytomic_ip_name"></a> [polytomic\_ip\_name](#input\_polytomic\_ip\_name) | The name of the GCP global static IP for ingress | `string` | n/a | yes |
| <a name="input_polytomic_logger_image"></a> [polytomic\_logger\_image](#input\_polytomic\_logger\_image) | Image name for the Vector DaemonSet. | `string` | `"polytomic-vector"` | no |
| <a name="input_polytomic_logger_image_tag"></a> [polytomic\_logger\_image\_tag](#input\_polytomic\_logger\_image\_tag) | Tag for the Vector DaemonSet image. Defaults to polytomic\_image\_tag when not set. | `string` | `null` | no |
| <a name="input_polytomic_logger_service_account"></a> [polytomic\_logger\_service\_account](#input\_polytomic\_logger\_service\_account) | Optional GCP service account email for Vector DaemonSet Workload Identity. Defaults to polytomic\_service\_account when unset. | `string` | `null` | no |
| <a name="input_polytomic_managed_logs"></a> [polytomic\_managed\_logs](#input\_polytomic\_managed\_logs) | Enable Datadog log forwarding for both embedded Vector and DaemonSet. | `bool` | `false` | no |
| <a name="input_polytomic_root_user"></a> [polytomic\_root\_user](#input\_polytomic\_root\_user) | The root user for the polytomic deployment | `string` | `"root"` | no |
| <a name="input_polytomic_service_account"></a> [polytomic\_service\_account](#input\_polytomic\_service\_account) | GCP service account email for Workload Identity annotation on the Polytomic pods | `string` | n/a | yes |
| <a name="input_polytomic_url"></a> [polytomic\_url](#input\_polytomic\_url) | The url for the polytomic deployment (hostname only, e.g., polytomic.example.com) | `string` | n/a | yes |
| <a name="input_polytomic_use_dd_agent"></a> [polytomic\_use\_dd\_agent](#input\_polytomic\_use\_dd\_agent) | Deploy Datadog Agent DaemonSet for APM tracing. | `bool` | `false` | no |
| <a name="input_polytomic_use_logger"></a> [polytomic\_use\_logger](#input\_polytomic\_use\_logger) | Deploy Vector DaemonSet for stdout/stderr log collection. Disable to reduce costs in dev environments or if using alternative log collection. | `bool` | `true` | no |
| <a name="input_postgres_host"></a> [postgres\_host](#input\_postgres\_host) | The host for the PostgreSQL instance (private IP) | `string` | n/a | yes |
| <a name="input_postgres_password"></a> [postgres\_password](#input\_postgres\_password) | The password for the PostgreSQL instance | `string` | n/a | yes |
| <a name="input_redis_host"></a> [redis\_host](#input\_redis\_host) | The host for the Redis instance | `string` | n/a | yes |
| <a name="input_redis_password"></a> [redis\_password](#input\_redis\_password) | The password for the Redis instance | `string` | n/a | yes |
| <a name="input_redis_port"></a> [redis\_port](#input\_redis\_port) | The port for the Redis instance | `number` | `6379` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout in seconds for waiting for resources to be ready. Only used when wait is true. | `number` | `600` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Wait for all Kubernetes resources to be ready before marking the release as successful. | `bool` | `false` | no |

## Outputs

No outputs.
