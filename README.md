# homelab
Evgeny's HomeLab Kubernetes Cluster Configurations (non-sensitive)

This repository contains all the instructions, configurations and scripts for configuring Evgeny's HomeLab Kubernetes cluster. Any sensitive (secrets) are not stored in repository however may be referenced in the instructions.

## Install Kubernetes Cluster

### Install Ubuntu Server OS

Grab an image, stick on a USB, and follow install instructions.

Enable ssh, don't install microk8s, already done in install script.

### Deploy and run install script

Clone this repo onto the target cluster

```sh
git clone https://github.com/eyjohn/homelab
cd homelab
```

Run the `install.sh` script which will:

- Laptop lid-closing fix
- Install microk8s and enable user access
- Enable useful microk8s modules

## Setup connectivity

### Enable router/firewall access

Since this is running on my LAN, the router needs 
- Port-forward for direct ports (e.g. 80, 443)

### Acquire cluster connection config

For easier (remote) control using `kubectl` and `helm`, fetch the connection details for kubectl using. The setup in this runbook exposes the kubernetes api-service publicly with a valid certificate, however local access can be received using a local network configuration.

#### Generate local config

This config will only work on the local network.

```sh
ssh homelab.lan /snap/bin/microk8s config > ~/.kube/microk8s.config
```

#### Generate remote config

This config will work remotely (and securely).

```sh
ssh homelab.lan /snap/bin/microk8s config -l | grep -v certificate-authority-data | sed 's/: microk8s/: homelab/g;s/127\.0\.0\.1:16443/kubernetes.homelab.evdev.me/g' > ~/.kube/homelab.config
```

#### Validate connectivity

```sh
kubectl get nodes
```

## Configure Kubernetes Cluster

### Install Helm

Helm is used for installing charts (groups of resources).

[Get Helm](https://github.com/helm/helm/releases)

As of version 3, helm no longer requires a service installed on the kubernetes cluster itself.

### Run configure script

The `configure.sh` script can be run either on the cluster itself, or remotely as long as kubectl can access the cluster. This script will

- Install and Configure cert-manager
- Install ingress-nginx
- Apply local ingress configurations (for router http, kubernetes end-point and dashboard)

### Install Brigade

This brigade setup integrates with GitHub using the brigade-github-app chart. This requires configuration on GitHub and a publicly accessible URL. See [brigade-github-app documentation](https://github.com/brigadecore/brigade-github-app) for more information for the complete setup. The rest of this section describes only the kubernetes cluster setup.

Add Brigade to local repo and install Brigade on cluster

```sh
kubectl create namespace brigade
helm repo add brigade https://brigadecore.github.io/charts
helm repo update
helm install brigade brigade/brigade --namespace=brigade -f brigade/values.yaml -f $PRIV/brigade/brigade-github-key.yaml
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
