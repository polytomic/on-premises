## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.0, < 8.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_network"></a> [gcp\_network](#module\_gcp\_network) | terraform-google-modules/network/google | ~> 12.0 |
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google//modules/private-cluster | ~> 35.0 |
| <a name="module_memorystore"></a> [memorystore](#module\_memorystore) | terraform-google-modules/memorystore/google | ~> 12.0 |
| <a name="module_postgres"></a> [postgres](#module\_postgres) | GoogleCloudPlatform/sql-db/google//modules/postgresql | ~> 23.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.load_balancer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_address.private_ip_address](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network_peering_routes_config.peering_routes](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_peering_routes_config) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.nat](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_service_networking_connection.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |
| [google_storage_bucket.polytomic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.polytomic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.polytomic_logger](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The GCS bucket name to use. Must be globally unique. | `string` | `""` | no |
| <a name="input_cluster_deletion_protection"></a> [cluster\_deletion\_protection](#input\_cluster\_deletion\_protection) | Whether to enable deletion protection on the GKE cluster | `bool` | `true` | no |
| <a name="input_cluster_service_account"></a> [cluster\_service\_account](#input\_cluster\_service\_account) | The service account to use for the cluster | `string` | n/a | yes |
| <a name="input_create_postgres"></a> [create\_postgres](#input\_create\_postgres) | Whether to create a Cloud SQL PostgreSQL instance | `bool` | `true` | no |
| <a name="input_create_redis"></a> [create\_redis](#input\_create\_redis) | Whether to create a Memorystore Redis instance | `bool` | `true` | no |
| <a name="input_database_availability_type"></a> [database\_availability\_type](#input\_database\_availability\_type) | Availability type for Cloud SQL (REGIONAL for HA, ZONAL for single zone) | `string` | `"REGIONAL"` | no |
| <a name="input_database_backup_retention"></a> [database\_backup\_retention](#input\_database\_backup\_retention) | Number of backups to retain | `number` | `30` | no |
| <a name="input_database_deletion_protection"></a> [database\_deletion\_protection](#input\_database\_deletion\_protection) | Whether to enable deletion protection on the database | `bool` | `true` | no |
| <a name="input_database_disk_autoresize"></a> [database\_disk\_autoresize](#input\_database\_disk\_autoresize) | Whether to enable disk autoresize | `bool` | `true` | no |
| <a name="input_database_disk_autoresize_limit"></a> [database\_disk\_autoresize\_limit](#input\_database\_disk\_autoresize\_limit) | Maximum disk size in GB when autoresize is enabled (0 = unlimited) | `number` | `100` | no |
| <a name="input_database_disk_size"></a> [database\_disk\_size](#input\_database\_disk\_size) | Disk size in GB for the Cloud SQL instance | `number` | `20` | no |
| <a name="input_database_edition"></a> [database\_edition](#input\_database\_edition) | The edition of the Cloud SQL instance (ENTERPRISE or ENTERPRISE\_PLUS) | `string` | `"ENTERPRISE"` | no |
| <a name="input_database_maintenance_window_day"></a> [database\_maintenance\_window\_day](#input\_database\_maintenance\_window\_day) | Day of the week for maintenance window (1=Mon, 7=Sun) | `number` | `7` | no |
| <a name="input_database_maintenance_window_hour"></a> [database\_maintenance\_window\_hour](#input\_database\_maintenance\_window\_hour) | Hour of the day for maintenance window (0-23) | `number` | `0` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database to create | `string` | `"polytomic"` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Username for the database | `string` | `"polytomic"` | no |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Cloud SQL database version | `string` | `"POSTGRES_17"` | no |
| <a name="input_desired_size"></a> [desired\_size](#input\_desired\_size) | Initial number of nodes in the node pool | `number` | `3` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Machine type for GKE nodes | `string` | `"e2-standard-4"` | no |
| <a name="input_ip_range_pods_name"></a> [ip\_range\_pods\_name](#input\_ip\_range\_pods\_name) | The secondary ip range to use for pods | `string` | `"ip-range-pods"` | no |
| <a name="input_ip_range_services_name"></a> [ip\_range\_services\_name](#input\_ip\_range\_services\_name) | The secondary ip range to use for services | `string` | `"ip-range-services"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_logger_workload_identity_sa"></a> [logger\_workload\_identity\_sa](#input\_logger\_workload\_identity\_sa) | Optional email of a dedicated logger workload identity service account that should also receive bucket write access | `string` | `""` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | Maximum number of nodes in the node pool | `number` | `4` | no |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | Minimum number of nodes in the node pool | `number` | `2` | no |
| <a name="input_postgres_instance_tier"></a> [postgres\_instance\_tier](#input\_postgres\_instance\_tier) | The tier (machine type) of the Cloud SQL instance | `string` | `"db-custom-2-7680"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resource names | `string` | `"polytomic"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID to host the cluster in | `string` | n/a | yes |
| <a name="input_redis_auth_enabled"></a> [redis\_auth\_enabled](#input\_redis\_auth\_enabled) | Whether to enable AUTH on the Redis instance | `bool` | `true` | no |
| <a name="input_redis_maintenance_window_day"></a> [redis\_maintenance\_window\_day](#input\_redis\_maintenance\_window\_day) | Day of the week for Redis maintenance (MONDAY through SUNDAY) | `string` | `"MONDAY"` | no |
| <a name="input_redis_maintenance_window_hour"></a> [redis\_maintenance\_window\_hour](#input\_redis\_maintenance\_window\_hour) | Hour for Redis maintenance window (0-23 UTC) | `number` | `3` | no |
| <a name="input_redis_size"></a> [redis\_size](#input\_redis\_size) | The size of the Redis instance in GB | `number` | `1` | no |
| <a name="input_redis_transit_encryption_mode"></a> [redis\_transit\_encryption\_mode](#input\_redis\_transit\_encryption\_mode) | Transit encryption mode for Redis (DISABLED or SERVER\_AUTHENTICATION) | `string` | `"DISABLED"` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | Redis version for Memorystore | `string` | `"REDIS_7_2"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to host the cluster in | `string` | `"us-east1"` | no |
| <a name="input_workload_identity_sa"></a> [workload\_identity\_sa](#input\_workload\_identity\_sa) | The email of the workload identity user service account | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | GCS bucket name |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | GKE cluster name |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Configured PostgreSQL database name |
| <a name="output_database_username"></a> [database\_username](#output\_database\_username) | Configured PostgreSQL database username |
| <a name="output_lb_ip"></a> [lb\_ip](#output\_lb\_ip) | Load balancer IP address |
| <a name="output_lb_name"></a> [lb\_name](#output\_lb\_name) | Load balancer IP name |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | VPC network ID |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | VPC network name |
| <a name="output_postgres_host"></a> [postgres\_host](#output\_postgres\_host) | PostgreSQL instance connection name |
| <a name="output_postgres_ip"></a> [postgres\_ip](#output\_postgres\_ip) | PostgreSQL private IP address |
| <a name="output_postgres_password"></a> [postgres\_password](#output\_postgres\_password) | PostgreSQL generated user password |
| <a name="output_redis_auth_string"></a> [redis\_auth\_string](#output\_redis\_auth\_string) | Redis AUTH string |
| <a name="output_redis_host"></a> [redis\_host](#output\_redis\_host) | Redis host |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | Redis port |
| <a name="output_sa"></a> [sa](#output\_sa) | Service account used by the cluster |
| <a name="output_workload_identity_user_sa"></a> [workload\_identity\_user\_sa](#output\_workload\_identity\_user\_sa) | Workload Identity service account email — send to Polytomic for registry access |
