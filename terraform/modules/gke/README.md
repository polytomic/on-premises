## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_network"></a> [gcp\_network](#module\_gcp\_network) | terraform-google-modules/network/google | 6.0.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/private-cluster | 24.1.0 |
| <a name="module_memorystore"></a> [memorystore](#module\_memorystore) | terraform-google-modules/memorystore/google | n/a |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | GoogleCloudPlatform/sql-db/google//modules/postgresql | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.load_balancer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network_peering_routes_config.peering_routes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_service_networking_connection.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_service_account"></a> [cluster\_service\_account](#input\_cluster\_service\_account) | The service account to use for the cluster | `any` | n/a | yes |
| <a name="input_create_postgres"></a> [create\_postgres](#input\_create\_postgres) | Whether to create a postgres instance | `bool` | `true` | no |
| <a name="input_create_redis"></a> [create\_redis](#input\_create\_redis) | Whether to create a redis instance | `bool` | `true` | no |
| <a name="input_ip_range_pods_name"></a> [ip\_range\_pods\_name](#input\_ip\_range\_pods\_name) | The secondary ip range to use for pods | `string` | `"ip-range-pods"` | no |
| <a name="input_ip_range_services_name"></a> [ip\_range\_services\_name](#input\_ip\_range\_services\_name) | The secondary ip range to use for services | `string` | `"ip-range-services"` | no |
| <a name="input_postgres_instance_tier"></a> [postgres\_instance\_tier](#input\_postgres\_instance\_tier) | The tier of the postgres instance | `string` | `"db-f1-micro"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The project ID to host the cluster in | `any` | n/a | yes |
| <a name="input_redis_size"></a> [redis\_size](#input\_redis\_size) | The size of the redis instance in GB | `string` | `"1"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | `"us-east1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | Cluster name |
| <a name="output_lb_ip"></a> [lb\_ip](#output\_lb\_ip) | Load balancer IP |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | Load balancer IP Name |
| <a name="output_postgres_host"></a> [postgres\_host](#output\_postgres\_host) | n/a |
| <a name="output_postgres_ip"></a> [postgres\_ip](#output\_postgres\_ip) | n/a |
| <a name="output_postgres_password"></a> [postgres\_password](#output\_postgres\_password) | n/a |
| <a name="output_redis_auth_string"></a> [redis\_auth\_string](#output\_redis\_auth\_string) | n/a |
| <a name="output_redis_host"></a> [redis\_host](#output\_redis\_host) | n/a |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | n/a |
| <a name="output_sa"></a> [sa](#output\_sa) | Service account |
