
- install tiller

```sh
helm repo add brigade https://brigadecore.github.io/charts
helm install -n brigade brigade/brigade --set rbac.enabled=true --namespace=brigade
```
