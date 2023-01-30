# Polytomic GKE Module


## Prerequisites 

Create service account before applying the entire module

```sh
terraform apply -target module.gke_cluster_service_account
```

Take note of the outputted service account principle this must be whitelisted 
to access the Polytomic container registry.


## After applying
Ensure the load_balancer_ip that is outputted by the terraform has an A record in your DNS for the provided URL.


## TLS

### Google Managed Certificates

This example creates a Google Manage Certificate for TLS termination.


Note: Provisioning TLS certs with google will can take a long time. This will usually take around 60 minutes.

### BYOC (Bring your own certs)

If you would prefer to use your own certs for TLS termination, you can import them into GCP.

```sh
gcloud compute ssl-certificates create my-polytomic-cert \
--certificate my-cert.pem \
--private-key my-key.key
```

The `ingress.gcp.kubernetes.io/pre-shared-cert:` ingress annotation can be updated to reference this newly imported cert.