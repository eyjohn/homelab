# evkube
EvKube Kubernetes Cluster Configurations (non-sensitive)

This repository contains all the instructions, configurations and scripts for configuring Evgeny's Kubernetes cluster. Any sensitive (secrets) are not stored in repository however may be referenced in the instructions.

## Creating the Kubernetes cluster

These instructions are for Kubernetes hosted on Google Cloud Platform.

### Create the cluster

```sh
gcloud container clusters create evkube --num-nodes 1 --disk-size 15 -m g1-small --no-enable-cloud-logging --no-enable-cloud-monitoring
```

- Micro instance was unusable
- 30GB disk is free-tier, chose 15GB incase incase I want two nodes
- Not enough for monitoring/logging bundles even for g1-small

Total Estimated Cost: USD 14.40 per 1 month (US-East July 2019)

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
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml
# or local copy:
# kubectl apply -f cert-manager/00-crds.yaml
kubectl apply -f cert-manager/production-issuer.yaml
```

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install -n cert-manager --namespace cert-manager jetstack/cert-manager
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

This brigade setup integrates with GitHub using the brigade-github-app chart. This requires configuration on GitHub and a publicly accessible URL. See [brigade-github-app documentation](https://github.com/brigadecore/brigade-github-app) for more information for the complete setup. The rest of this section describes only the kubernetes cluster setup.

Add Brigade to local repo and install Brigade on cluster

```sh
helm repo add brigade https://brigadecore.github.io/charts
helm repo update
helm install -n brigade brigade/brigade --namespace=brigade -f brigade/values.yaml -f $PRIV/brigade/brigade-github-key.yaml
```

- rbac permissioning needs to be enabled
- chart will be deployed with the name `brigade` in namespace `brigade`

### Adding Brigade Projects

Before running `brig` make sure to `export BRIGADE_NAMESPACE=brigade`.

The `brig` tool can be found [here](https://github.com/brigadecore/brigade/tree/master/brig).

To create a new project:
```sh
brig project create
```
_(shared secret is stored in the priv repo)_
