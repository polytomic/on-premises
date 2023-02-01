# Polytomic EKS Module


This module has two stages:
- cluster install
- app install


The cluster module must be applied before running the app module.


## Cluster Install

```sh
cd cluster 
terraform init
```


Fill in the `locals` block at the top with the desired values.

```sh
terraform apply
```

## App Install

```sh
cd app 
terraform init
terraform apply
```

Obtain the ingress loadbalancer name to create a CNAME record in your DNS.
```
aws eks update-kubeconfig --name ${YOUR LOCAL.PREFIX VALUE}-cluster --region ${YOUR LOCAL.REGION VALUE}
kubectl get ingress -n polytomic
```