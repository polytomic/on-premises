## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0, < 7.0.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lb_role"></a> [lb\_role](#module\_lb\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.0 |
| <a name="module_polytomic_role"></a> [polytomic\_role](#module\_polytomic\_role) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts | ~> 6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.polytomic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.lb](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_service_account_v1.service-account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [aws_iam_policy_document.polytomic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name | `any` | n/a | yes |
| <a name="input_oidc_provider_arn"></a> [oidc\_provider\_arn](#input\_oidc\_provider\_arn) | OIDC provider ARN | `any` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | `"polytomic"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_polytomic_role_arn"></a> [polytomic\_role\_arn](#output\_polytomic\_role\_arn) | n/a |
