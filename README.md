<div align="center">
  <img src="assets/logo/logo.svg" alt="Mimir Sync Logo" width="200">
  
  # Mimir Sync
</div>

A Helm chart for syncing Alertmanager configurations and Prometheus rules to a Mimir instance using Kubernetes Jobs.

## Quick Start

### Installation from Helm Repository

Add the repository and install the chart:

```bash
# Add the Helm repository
helm repo add mimir-sync https://antnsn.github.io/mimir-sync
helm repo update

# Install the chart
helm install mimir-sync mimir-sync/mimir-sync -n mimir-sync --create-namespace \
  --set mimir.address=http://mimir-distributed-nginx.mimir.svc.cluster.local:80 \
  --set mimir.tenantId=anonymous
```

### Installation from Local Chart

For local development or testing, you can install directly from the chart directory:

```bash
helm install mimir-sync ./chart -n mimir-sync --create-namespace \
  --set mimir.address=http://mimir-distributed-nginx.mimir.svc.cluster.local:80 \
  --set mimir.tenantId=anonymous
```

### Artifact Hub

This chart is also available on [![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/mimir-sync)](https://artifacthub.io/packages/helm/mimir-sync/mimir-sync)

## Configuration

Key configurations in `values.yaml`:

```yaml
mimir:
  address: http://mimir-distributed-nginx.mimir.svc.cluster.local:80
  tenantId: anonymous
  # user: ""
  # password: ""

image:
  repository: grafana/mimirtool
  tag: latest
  pullPolicy: IfNotPresent

alertmanager:
  enabled: true
  config:
    type: configmap # or 'secret'
    existingName: "" # name of existing ConfigMap/Secret
    key: config.yml

rules:
  enabled: true
  config:
    type: configmap # or 'secret'
    existingName: "" # name of existing ConfigMap/Secret
    key: rules.yml
```

## How It Works

1. The chart creates Kubernetes Jobs that run to sync configurations to Mimir
2. Jobs are triggered when ConfigMaps/Secrets change (requires Reloader)
3. Jobs use `grafana/mimirtool` to sync configurations
4. Completed jobs are automatically cleaned up

## Maintenance

### Updating the Helm Chart

When you make changes to the chart, follow these steps to update the Helm repository:

1. Update the version in `chart/Chart.yaml`
2. Package the chart and update the repository index:

```bash
# Package the chart
helm package chart/ -d /tmp/helm-repo

# Update the repository index
cd /tmp/helm-repo
helm repo index . --url https://antnsn.github.io/mimir-sync

# Commit and push changes
git add .
git commit -m "Update chart to version X.Y.Z"
git push
```

## License

GNU General Public License v3.0
