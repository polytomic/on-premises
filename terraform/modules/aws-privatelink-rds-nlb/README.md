## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |
| <a name="requirement_dns"></a> [dns](#requirement\_dns) | >= 3.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 7.0 |
| <a name="provider_dns"></a> [dns](#provider\_dns) | >= 3.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_lb.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_security_group_rule.rds_from_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpc_endpoint_service.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_service) | resource |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [dns_a_record_set.rds](https://registry.terraform.io/providers/hashicorp/dns/latest/docs/data-sources/a_record_set) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name prefix applied to the NLB, target group, and endpoint service. | `string` | `"polytomic-privatelink"` | no |
| <a name="input_polytomic_aws_account_id"></a> [polytomic\_aws\_account\_id](#input\_polytomic\_aws\_account\_id) | The AWS account ID Polytomic will use to create the consumer-side VPC<br/>endpoint. Polytomic will provide this — ask your Solutions Engineer if you<br/>don't have it. This account is added to the VPC Endpoint Service's<br/>`allowed_principals`. | `string` | n/a | yes |
| <a name="input_rds_host"></a> [rds\_host](#input\_rds\_host) | The RDS instance hostname (the `address` attribute of `aws_db_instance`,<br/>e.g. `mydb.xxxxxxxxxxxx.us-east-1.rds.amazonaws.com`). Resolved once at<br/>apply time to an IP that is registered as an NLB target.<br/><br/>IMPORTANT: NLBs only support IP targets, not DNS. If RDS fails over to a<br/>different IP, connections via PrivateLink will break until this module is<br/>re-applied. If you are running RDS Multi-AZ and need failover tolerance,<br/>use the `aws-privatelink-rds-lattice` module instead. | `string` | n/a | yes |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Postgres port on the RDS instance. | `number` | `5432` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | The security group attached to the RDS instance. A rule is added allowing<br/>inbound traffic from the VPC CIDR on `rds_port` so the NLB's IP targets<br/>can reach RDS. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Private subnet IDs in which to place the NLB. Provide at least two across<br/>distinct AZs for high availability. These must be able to route to the<br/>RDS instance's IP. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC hosting the existing RDS instance. The NLB is created in this VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | n/a |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | The VPC Endpoint Service ID. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | The VPC Endpoint Service name. Send this string to your Polytomic Solutions<br/>Engineer — they will configure Polytomic's side to create a VPC endpoint<br/>against it. |
| <a name="output_target_ip"></a> [target\_ip](#output\_target\_ip) | RDS IP resolved at apply time and registered as the NLB target. |
