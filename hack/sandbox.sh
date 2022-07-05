#!/bin/bash

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
echo "Loading polytomic image 📦 ..."
# Load polytomic docker image into kind
kind load docker-image polytomic-jake
echo "Image loaded 🎉"
echo
echo
echo "Installing NGINX ingress controller 🚀 ..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# Ingress controller pre-flight checks
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
echo "NGINX ingress controller installed 🎉"
# echo
# echo
# echo "Installing Ceph 🚀 ..."
# pushd helm/rook/rook-ceph
# helm install rook-ceph .
# popd
# pushd helm/rook/rook-ceph-cluster
# helm install rook-ceph-cluster .
# popd
# echo "Ceph installed 🎉"
echo
echo
echo "Installing Polytomic 🚀 ..."
pushd helm/polytomic
helm dep up
helm install polytomic .
popd
echo "Polytomic installed 🎉"
