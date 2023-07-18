#!/bin/bash

POLYTOMIC_IMAGE_REPO=568237466542.dkr.ecr.us-west-2.amazonaws.com/polytomic-onprem

# Ensure kind is installed
if ! command -v kind >/dev/null; then
  echo "kind is not installed 😥. Please install kind before running this script. https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
  exit 1
fi

# Ensure helm is installed
if ! command -v helm >/dev/null; then
  echo "helm is not installed 😥. Please install helm before running this script. https://helm.sh/docs/helm/helm_install/"
  exit 1
fi

cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF
echo
echo
echo
echo "Installing NGINX ingress controller 🚀 ..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
sleep 30
echo
echo "Waiting for NGINX to become ready. This may take a bit..."
# Ingress controller pre-flight checks
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo "NGINX ingress controller installed 🎉"
echo
