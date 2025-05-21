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

## Releasing a New Version

### Using the Release Script (Recommended)

We provide a release script that automates the entire release process:

```bash
# Make the script executable if it's not already
chmod +x scripts/release.sh

# Run the release script
./scripts/release.sh
```

#### Dry Run Mode

To see what the script would do without making any changes:

```bash
./scripts/release.sh --dry-run
```

This will show what would be committed, which tag would be created, and what would be pushed, without making any actual changes.

#### What the Script Does

1. Validates the new version number (must follow semantic versioning)
2. Updates the chart version in `chart/Chart.yaml`
3. Optionally updates the `appVersion` if requested
4. Runs `helm lint` to validate the chart
5. Updates the documentation using `helm-docs`
6. Shows a diff of all changes
7. Asks for confirmation before proceeding
8. Commits the changes, creates an annotated tag, and pushes everything

#### Prerequisites

The script requires:
- `git` - For version control operations
- `helm` - For linting the chart
- `go` - For installing `helm-docs` if not already installed
- `helm-docs` - For generating documentation (will be installed automatically if needed)

### Manual Release Process

If you prefer to do it manually:

1. **Update the chart version** in `chart/Chart.yaml` following [semantic versioning](https://semver.org/):
   ```yaml
   version: 1.0.0  # Update this version
   appVersion: "1.0.0"  # Update if the app version changes
   ```

2. **Commit and push** the changes to the `main` branch:
   ```bash
   git add chart/Chart.yaml
   git commit -m "chore: prepare for vX.Y.Z release"
   git push origin main
   ```

3. **Create and push a new tag** which will trigger the release workflow:
   ```bash
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   git push origin vX.Y.Z
   ```

The GitHub Actions workflow will automatically:
- Package the chart
- Update the Helm repository index
- Publish the new version to the GitHub Pages site

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
