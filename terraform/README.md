# Polytomic Terraform


## Contributing


## Using locally
The best way to make and test changes to the modules it by editing the desired module (e.g. `modules/ecs`) and running terraform inside the minimal example for the given module (e.g. `examples/ecs-minimal`)

```
cd examples/ecs-minimal
terraform init
terraform plan
terraform apply
```

To target specific resources for testing, you can provide a target. For example, if you just want to test bucket creation in the ecs module you can run:

```
terraform plan -target module.polytomic-ecs.module.s3_bucket

terraform apply -target module.polytomic-ecs.module.s3_bucket
```


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