# Polytomic Terraform


## Contributing

### Formatting

Uses Terraform [fmt](https://www.terraform.io/cli/commands/fmt).
```
make format
```

### Docs
Terraform module documentation is generated with [terraform-docs](https://terraform-docs.io/).

Install by following the steps [here](https://terraform-docs.io/user-guide/installation/).

```
make generate-docs
```

### Security
Terraform SAST is accomplished with [tfsec](https://github.com/aquasecurity/tfsec).

Install by following the steps [here](https://aquasecurity.github.io/tfsec/v1.26.0/guides/installation/).

```
make scan
```