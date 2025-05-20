# Mimir Sync Helm Chart

Sync Alertmanager configurations and Prometheus rules to Mimir using Kubernetes Jobs.

## Installation

```bash
helm install mimir-sync ./ -n mimir-sync --create-namespace \
  --set mimir.address=http://mimir-distributed-nginx.mimir.svc.cluster.local:80 \
  --set mimir.tenantId=anonymous
```

## Configuration

Key parameters in `values.yaml`:

```yaml
mimir:
  address: http://mimir-distributed-nginx.mimir.svc.cluster.local:80
  tenantId: anonymous
  # user: ""
  # password: ""

alertmanager:
  enabled: true
  config:
    type: configmap  # or 'secret'
    existingName: ""  # name of existing ConfigMap/Secret
    key: config.yml

rules:
  enabled: true
  config:
    type: configmap  # or 'secret'
    existingName: ""  # name of existing ConfigMap/Secret
    key: rules.yml
```

## How It Works

1. The chart creates Kubernetes Jobs that sync configurations to Mimir
2. Jobs are triggered when ConfigMaps/Secrets change (requires Reloader)
3. Jobs use `grafana/mimirtool` to sync configurations
4. Completed jobs are automatically cleaned up

## Uninstalling

```bash
helm uninstall mimir-sync -n mimir-sync
```
