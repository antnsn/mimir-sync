# mimir-sync

![Version: 0.2.5](https://img.shields.io/badge/Version-0.2.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for syncing Mimir alertmanager config and Prometheus rules

**Homepage:** <https://github.com/antnsn/mimir-sync>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| antnsn | <me@antnsn.dev> | <https://github.com/antnsn> |

## Source Code

* <https://github.com/antnsn/mimir-sync>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| alertmanager.config.existingName | string | `""` |  |
| alertmanager.config.key | string | `"config.yml"` |  |
| alertmanager.config.type | string | `"secret"` |  |
| alertmanager.configPath | string | `"/config/config.yml"` |  |
| alertmanager.enabled | bool | `true` |  |
| alertmanager.resources | object | `{}` |  |
| alertmanagerConfig | string | `"global:\n  resolve_timeout: 5m\nroute:\n  group_by: ['alertname']\n  group_wait: 10s\n  group_interval: 5m\n  repeat_interval: 15m\n  receiver: someReceiver\n  routes:\n    - match:\n        severity: critical\n      receiver: someReceiver\n      group_wait: 10s\n      group_interval: 2m\n      repeat_interval: 5m\n    - match:\n        severity: warning\n      receiver: keep\n      group_wait: 10s\n      group_interval: 2m\n      repeat_interval: 5m\nreceivers:\n  - name: \"someReceiver\"\n    webhook_configs:\n      - url: \"https://someurl\"\n        send_resolved: true\n        http_config:\n          basic_auth:\n            username: someUsername\n            password: somePassword\n"` |  |
| global.commonAnnotations | object | `{}` |  |
| global.commonLabels | object | `{}` |  |
| global.createNamespace | bool | `true` |  |
| global.fullnameOverride | string | `""` |  |
| global.nameOverride | string | `""` |  |
| global.namespace | string | `"mimir-sync"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"grafana/mimirtool"` |  |
| image.tag | string | `"latest"` |  |
| mimir.address | string | `"http://mimir-distributed-nginx.mimir.svc.cluster.local:80"` |  |
| mimir.tenantId | string | `"anonymous"` |  |
| pod.affinity | object | `{}` |  |
| pod.annotations | object | `{}` |  |
| pod.disruptionBudget | object | `{}` |  |
| pod.env | list | `[]` |  |
| pod.initContainers | list | `[]` |  |
| pod.labels | object | `{}` |  |
| pod.nodeSelector | object | `{}` |  |
| pod.priorityClassName | string | `""` |  |
| pod.securityContext | object | `{}` |  |
| pod.serviceAccountTokenVolumeMountPath | string | `"/var/run/secrets/kubernetes.io/serviceaccount"` |  |
| pod.sidecarContainers | list | `[]` |  |
| pod.tolerations | list | `[]` |  |
| pod.topologySpreadConstraints | list | `[]` |  |
| pod.volumeMounts | list | `[]` |  |
| pod.volumes | list | `[]` |  |
| prometheusRules."node.yml" | string | `"groups:\n  - name: node-exporter\n    rules:\n      - alert: NodeDown\n        expr: up{job=~\"k8s-nodes|external-servers\"} == 0\n        for: 2m\n        labels:\n          severity: critical\n        annotations:\n          summary: Node down (instance {{ $labels.instance }})\n          description: \"Node is down or not responding\\n  VALUE = {{ $value }}\\n  LABELS = {{ $labels }}\"\n      - alert: HighNodeLoad\n        expr: node_load1 > 5\n        for: 5m\n        labels:\n          severity: warning\n        annotations:\n          description: '{{ $labels.instance }} has high load (current value: {{ $value }})'\n          summary: High load on {{ $labels.instance }}\n      - alert: HostOutOfMemory\n        expr: node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes * 100 < 10\n        for: 5m\n        labels:\n          severity: warning\n        annotations:\n          summary: Host out of memory (instance {{ $labels.instance }})\n          description: \"Node memory is filling up (< 10% left)\\n  VALUE = {{ $value }}\\n  LABELS = {{ $labels }}\"\n      - alert: HostHighCpuLoad\n        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 85\n        for: 10m\n        labels:\n          severity: warning\n        annotations:\n          summary: Host high CPU load (instance {{ $labels.instance }})\n          description: '{{ $labels.instance }} has high CPU load (current value: {{ $value }})'\n      - alert: HostOutOfDiskSpace\n        expr: (node_filesystem_avail_bytes{mountpoint=\"/\"}  / node_filesystem_size_bytes{mountpoint=\"/\"} * 100) < 10\n        for: 5m\n        labels:\n          severity: warning\n        annotations:\n          summary: Host out of disk space (instance {{ $labels.instance }})\n          description: \"Disk is almost full (< 10% left)\\n  VALUE = {{ $value }}\\n  LABELS = {{ $labels }}\"\n"` |  |
| rbac.create | bool | `true` |  |
| rules.config.existingName | string | `""` |  |
| rules.config.key | string | `"rules.yml"` |  |
| rules.config.type | string | `"secret"` |  |
| rules.enabled | bool | `true` |  |
| rules.resources | object | `{}` |  |
| rules.rulesPath | string | `"/rules"` |  |
| rules.url | string | `"http://mimir-ruler:8080"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.automountServiceAccountToken | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.imagePullSecrets | list | `[]` |  |
| serviceAccount.name | string | `""` |  |
| serviceAccount.name | string | `""` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
