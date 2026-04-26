{{ template "chart.header" . }}

{{ template "chart.description" . }}

{{ template "chart.versionBadge" . }}{{ template "chart.typeBadge" . }}{{ template "chart.appVersionBadge" . }}

`mimir-sync` is a Helm chart that deploys Kubernetes Jobs which use
[`mal-sync`](https://github.com/antnsn/mal-sync) — a thin wrapper around
[`mimirtool`](https://grafana.com/docs/mimir/latest/manage/tools/mimirtool/)
and [`lokitool`](https://grafana.com/docs/loki/latest/alert/#lokitool) — to
keep Alertmanager configuration, Prometheus recording/alerting rules, and Loki
recording/alerting rules in sync with a Mimir/Loki deployment.

## Installing

```bash
helm repo add mimir-sync https://antnsn.github.io/mimir-sync
helm repo update
helm install mimir-sync mimir-sync/mimir-sync \
  --namespace mimir-sync --create-namespace \
  --set mimir.address=http://mimir-distributed-nginx.mimir.svc.cluster.local:80 \
  --set mimir.tenantId=anonymous
```

{{ template "chart.maintainersSection" . }}

{{ template "chart.sourcesSection" . }}

{{ template "chart.requirementsSection" . }}

{{ template "chart.valuesHeader" . }}

{{ template "chart.valuesTable" . }}

{{ template "helm-docs.versionFooter" . }}
