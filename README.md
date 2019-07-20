# evkube
EvKube Kubernetes Cluster Configurations (non-sensitive)

This repository contains all the instructions, configurations and scripts for configuring Evgeny's Kubernetes cluster. Any sensitive (secrets) are not stored in repository however may be referenced in the instructions.

## Creating the Kubernetes cluster

These instructions are for Kubernetes hosted on Google Cloud Platform.

### Create the cluster

```sh
gcloud container clusters create evkube --num-nodes 3 --disk-size 10 -m f1-micro --no-enable-cloud-logging --no-enable-cloud-monitoring
```

- 3 nodes is the minimum configuration permittable for f1-micro instances
- 30GB disk is free-tier, hence 10 are per node
- f1-micro instances have only 600mb RAM, not enough for monitoring/logging bundles

Total Estimated Cost: USD 7.66 per 1 month (US-East July 2019)

Once created fetch credentials for use in kubectl/helm.
```sh
gcloud container clusters get-credentials evkube
```

### Install Helm

[Get Helm first](https://github.com/helm/helm/releases)

```sh
helm init --service-account tiller
```

### Install Nginx Ingress

TODO

### Install Cert Manager

### Install Brigade

Add Brigade to local repo first

```sh
helm repo add brigade https://brigadecore.github.io/charts
```

Install Brigade on cluster

```sh
helm install -n brigade brigade/brigade --namespace=brigade -f brigade.yaml
```

- rbac permissioning needs to be enabled
- chart will be deployed with the name `brigade` in namespace `brigade`
- before running `brig` make sure to `export BRIGADE_NAMESPACE=brigade`
