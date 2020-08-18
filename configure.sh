# Install cert-manager
echo "* Installing and configuring cert-manager"
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v0.16.1 \
  --set installCRDs=true
kubectl apply -f cert-manager/production-issuer.yaml

# Install ingress-nginx
echo "* Installing ingress-nginx"
kubectl create namespace ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install \
  ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  -f ingress-nginx/values.yaml

# Apply default ingress configurations
kubectl apply \
  -f home-http-ingress.yaml \
  -f kubernetes-ingress.yaml \
  -f kubernetes-dashboard.yaml
