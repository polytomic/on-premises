## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.60, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.60, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ram_principal_association.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_principal_association) | resource |
| [aws_ram_resource_association.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_association) | resource |
| [aws_ram_resource_share.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ram_resource_share) | resource |
| [aws_security_group.resource_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.rds_from_resource_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_vpclattice_resource_configuration.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_configuration) | resource |
| [aws_vpclattice_resource_gateway.pl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name prefix applied to the resource gateway, resource configuration, and RAM share. | `string` | `"polytomic-privatelink"` | no |
| <a name="input_polytomic_aws_account_id"></a> [polytomic\_aws\_account\_id](#input\_polytomic\_aws\_account\_id) | The AWS account ID Polytomic will use to create the consumer-side VPC<br/>endpoint. Polytomic will provide this — ask your Solutions Engineer if you<br/>don't have it. This account is added as a RAM principal on the resource<br/>share. | `string` | n/a | yes |
| <a name="input_rds_host"></a> [rds\_host](#input\_rds\_host) | The RDS instance hostname (the `address` attribute of `aws_db_instance`).<br/>Unlike the NLB variant, this is passed through to a `dns_resource` on the<br/>resource configuration — Lattice re-resolves it, so RDS failover is<br/>handled automatically. | `string` | n/a | yes |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Postgres port on the RDS instance. | `number` | `5432` | no |
| <a name="input_rds_security_group_id"></a> [rds\_security\_group\_id](#input\_rds\_security\_group\_id) | The security group attached to the RDS instance. A rule is added allowing<br/>inbound traffic on `rds_port` from the resource gateway's security group.<br/><br/>This is the step most manually-configured Lattice setups miss. Without it,<br/>connections reach the resource gateway but hang trying to reach RDS. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Private subnet IDs in which the VPC Lattice Resource Gateway is placed.<br/>These subnets must be able to route to the RDS instance. Provide at least<br/>two across distinct AZs for high availability. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources created by this module. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC hosting the existing RDS instance. The Resource Gateway is created in this VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ram_resource_share_arn"></a> [ram\_resource\_share\_arn](#output\_ram\_resource\_share\_arn) | n/a |
| <a name="output_resource_configuration_arn"></a> [resource\_configuration\_arn](#output\_resource\_configuration\_arn) | The Lattice Resource Configuration ARN. Send this string to your Polytomic<br/>Solutions Engineer — they will configure Polytomic's side to create a<br/>Resource-type VPC endpoint against it. |
| <a name="output_resource_gateway_id"></a> [resource\_gateway\_id](#output\_resource\_gateway\_id) | n/a |
