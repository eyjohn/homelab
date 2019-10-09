# evkube
EvKube Kubernetes Cluster Configurations (non-sensitive)

This repository contains all the instructions, configurations and scripts for configuring Evgeny's Kubernetes cluster. Any sensitive (secrets) are not stored in repository however may be referenced in the instructions.

## Creating the Kubernetes cluster

These instructions are for Kubernetes hosted on Google Cloud Platform.

### Create the cluster

```sh
# Small 
gcloud container clusters create evkube --num-nodes 2 --disk-size 15 -m g1-small

# Micro
gcloud container clusters create evkube --num-nodes 3 --disk-size 10 -m f1-micro --no-enable-cloud-logging --no-enable-cloud-monitoring
```

- 3 nodes is the minimum configuration permissible for f1-micro instances
- 30GB disk is free-tier, hence 10 are per node
- f1-micro instances have only 600mb RAM, not enough for monitoring/logging bundles, even for g1-small this could be a problem

Total Estimated Cost: USD 7.66 per 1 month (US-East July 2019)

Once created fetch credentials for use in kubectl/helm.
```sh
gcloud container clusters get-credentials evkube
```

### Install Helm

Helm is used for installing charts (groups of resources).

[Get Helm first](https://github.com/helm/helm/releases)

```sh
kubectl apply -f helm/tiller-rbac-config.yaml
helm init --service-account tiller
```

Check that it is running:
```sh
helm version
```

### Install Cert Manager

Use the cert-manager to generate free "lets-encrypt" SSL certificates.


Configure entity types and a default production issuer (cluster-wide)
```sh
kubectl apply -f cert-manager/00-crds.yaml
kubectl apply -f cert-manager/production-issuer.yaml
```

```sh
helm install -n cert-manager --namespace cert-manager stable/cert-manager
```

### Install Nginx Ingress

Rather than rely on external (expensive) load balancers, use nginx powered ingress to handle inbound traffic directly on nodes.

The current configuration uses `hostPort` to listen for incoming connection, a firewall port should be opened.

```sh
gcloud compute firewall-rules create nginx-ingress --allow tcp:80,tcp:443
```

Install nginx-ingress chart

```sh
helm install -n nginx-ingress --namespace nginx-ingress stable/nginx-ingress -f nginx-ingress/values.yaml 
```

### Install NFS storage provisioner

At the time of writing, GCE did not support ReadWriteMany ([see table](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes)).

This installs a NFS based storage provisioner (probably cheaper too).

```sh
helm install -n nfs-server-provisioner --namespace nfs-server-provisioner  stable/nfs-server-provisioner
```

### Install Brigade

Add Brigade to local repo first

```sh
helm repo add brigade https://brigadecore.github.io/charts
```

Install Brigade on cluster

```sh
helm install -n brigade brigade/brigade --namespace=brigade -f brigade/values.yaml -f $PRIV/brigade/brigade-github-key.yaml
```

- rbac permissioning needs to be enabled
- chart will be deployed with the name `brigade` in namespace `brigade`
- before running `brig` make sure to `export BRIGADE_NAMESPACE=brigade`
