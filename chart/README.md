# mimir-sync

![Version: 1.3.8](https://img.shields.io/badge/Version-1.3.8-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for syncing Mimir and Loki configurations including alertmanager config and rules

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
| alertmanager.affinity | object | `{}` |  |
| alertmanager.config.existingName | string | `""` |  |
| alertmanager.config.key | string | `"config.yml"` |  |
| alertmanager.config.type | string | `"secret"` |  |
| alertmanager.configPath | string | `"/config/config.yml"` |  |
| alertmanager.enabled | bool | `true` |  |
| alertmanager.extraEnv | list | `[]` |  |
| alertmanager.extraVolumeMounts | list | `[]` |  |
| alertmanager.extraVolumes | list | `[]` |  |
| alertmanager.imagePullSecrets | list | `[]` |  |
| alertmanager.nodeSelector | object | `{}` |  |
| alertmanager.resources | object | `{}` |  |
| alertmanager.templatesPathInContainer | string | `"/etc/alertmanager/templates"` |  |
| alertmanager.tolerations | list | `[]` |  |
| alertmanager.topologySpreadConstraints | list | `[]` |  |
| alertmanagerConfig | string | `""` |  |
| global.commonAnnotations | object | `{}` |  |
| global.commonLabels | object | `{}` |  |
| global.createNamespace | bool | `true` |  |
| global.fullnameOverride | string | `""` |  |
| global.nameOverride | string | `""` |  |
| global.namespace | string | `"mimir-sync"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ghcr.io/antnsn/mal-sync"` |  |
| image.tag | string | `"v1.0.0"` |  |
| loki.address | string | `"http://loki-distributed-gateway.loki.svc.cluster.local"` |  |
| loki.tenantId | string | `"anonymous"` |  |
| lokiRules.affinity | object | `{}` |  |
| lokiRules.backoffLimit | int | `2` |  |
| lokiRules.config.existingName | string | `""` |  |
| lokiRules.config.type | string | `"none"` |  |
| lokiRules.enabled | bool | `false` |  |
| lokiRules.extraEnv | list | `[]` |  |
| lokiRules.extraVolumeMounts | list | `[]` |  |
| lokiRules.extraVolumes | list | `[]` |  |
| lokiRules.imagePullSecrets | list | `[]` |  |
| lokiRules.nodeSelector | object | `{}` |  |
| lokiRules.resources | object | `{}` |  |
| lokiRules.rules | object | `{}` |  |
| lokiRules.rulesPathInContainer | string | `"/loki-rules"` |  |
| lokiRules.tolerations | list | `[]` |  |
| lokiRules.topologySpreadConstraints | list | `[]` |  |
| lokiRules.ttlSecondsAfterFinished | int | `3600` |  |
| mimir.address | string | `"http://mimir-distributed-nginx.mimir.svc.cluster.local:80"` |  |
| mimir.tenantId | string | `"anonymous"` |  |
| namespaces.loki | string | `"default"` |  |
| namespaces.mimir | string | `"default"` |  |
| prometheusRules | object | `{}` |  |
| rbac.create | bool | `true` |  |
| rules.affinity | object | `{}` |  |
| rules.config.existingName | string | `""` |  |
| rules.config.key | string | `"rules.yml"` |  |
| rules.config.type | string | `"secret"` |  |
| rules.enabled | bool | `true` |  |
| rules.extraEnv | list | `[]` |  |
| rules.extraVolumeMounts | list | `[]` |  |
| rules.extraVolumes | list | `[]` |  |
| rules.imagePullSecrets | list | `[]` |  |
| rules.nodeSelector | object | `{}` |  |
| rules.resources | object | `{}` |  |
| rules.rulesPath | string | `"/rules"` |  |
| rules.tolerations | list | `[]` |  |
| rules.topologySpreadConstraints | list | `[]` |  |
| rules.url | string | `"http://mimir-ruler:8080"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |

