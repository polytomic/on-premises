# Polytomic GKE Module


This module has two stages:
- cluster install
- app install


The cluster module must be applied before running the app module.


## Cluster Install

```sh
cd cluster 
terraform init
```


```sh
terraform apply
```
## After applying
Ensure the load_balancer_ip that is outputted by the terraform has an A record in your DNS for the provided URL.

Take note of the outputted service account principle this must be whitelisted 
to access the Polytomic container registry.



## App Install

```sh
cd app 
terraform init
terraform apply
```

## TLS

### Google Managed Certificates

This example creates a Google Manage Certificate for TLS termination.


Note: Provisioning TLS certs with google will can take a long time. This will usually take around 10-15 minutes but can take up to 60+ minutes.

### BYOC (Bring your own certs)

If you would prefer to use your own certs for TLS termination, you can import them into GCP.

```sh
gcloud compute ssl-certificates create my-polytomic-cert \
--certificate my-cert.pem \
--private-key my-key.key
```

The `ingress.gcp.kubernetes.io/pre-shared-cert:` ingress annotation can be updated to reference this newly imported cert.