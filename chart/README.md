# mimir-sync

![Version: 3.0.2](https://img.shields.io/badge/Version-3.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.0.0](https://img.shields.io/badge/AppVersion-3.0.0-informational?style=flat-square)

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
| alertmanager.affinity | object | `{}` | Affinity rules for the alertmanager sync Job. |
| alertmanager.backoffLimit | int | `2` | Job .spec.backoffLimit. |
| alertmanager.config.existingName | string | `""` | Use an existing ConfigMap/Secret instead of letting the chart create one. |
| alertmanager.config.key | string | `"config.yml"` | Key inside the ConfigMap/Secret that holds the Alertmanager config. |
| alertmanager.config.type | string | `"secret"` | One of: configmap, secret, none. "none" disables the built-in mount (use extraVolumes/extraVolumeMounts to provide your own). |
| alertmanager.configContent | string | `""` | Alertmanager configuration content (YAML string). Used only when config.type is "configmap" or "secret" and config.existingName is empty. |
| alertmanager.enabled | bool | `true` | Enable the Alertmanager sync Job. |
| alertmanager.extraEnv | list | `[]` | Extra environment variables for the alertmanager sync Job. |
| alertmanager.extraVolumeMounts | list | `[]` | Extra volume mounts for the alertmanager sync Job. |
| alertmanager.extraVolumes | list | `[]` | Extra volumes for the alertmanager sync Job. |
| alertmanager.imagePullSecrets | list | `[]` | Image pull secrets for the alertmanager sync Job. |
| alertmanager.nodeSelector | object | `{}` | Node selector for the alertmanager sync Job. |
| alertmanager.resources | object | `{}` | Resource requests and limits for the alertmanager sync Job. |
| alertmanager.syncTempDir | string | `""` | Optional temp dir used by mal-sync. |
| alertmanager.templatesPathInContainer | string | `"/etc/alertmanager/templates"` | Path inside the container where Alertmanager templates are mounted. |
| alertmanager.tolerations | list | `[]` | Tolerations for the alertmanager sync Job. |
| alertmanager.topologySpreadConstraints | list | `[]` | Topology spread constraints for the alertmanager sync Job. |
| alertmanager.ttlSecondsAfterFinished | int | `3600` | Job .spec.ttlSecondsAfterFinished (auto-GC of completed jobs). |
| commonAnnotations | object | `{}` | Common annotations applied to every resource rendered by this chart. Note: Reloader annotations on Jobs are merged with these. |
| commonLabels | object | `{}` | Common labels applied to every resource rendered by this chart. |
| containerSecurityContext | object | `{}` | Container-level securityContext applied to each Job container (toYaml'd as-is). Use this for fields like runAsNonRoot, allowPrivilegeEscalation, readOnlyRootFilesystem, capabilities. |
| fullnameOverride | string | `""` | Override the fully qualified app name. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| image.repository | string | `"ghcr.io/antnsn/mal-sync"` | Image repository for the mal-sync wrapper around mimirtool/lokitool. |
| image.tag | string | `""` | Image tag. When empty, the chart falls back to .Chart.AppVersion so the image stays pinned to a chart release. Set explicitly to override. |
| loki.address | string | `"http://loki-distributed-gateway.loki.svc.cluster.local"` | Loki API endpoint. |
| loki.existingSecret.key | string | `""` | Key inside the Secret that holds the password. |
| loki.existingSecret.name | string | `""` | Name of an existing Secret containing the Loki password. |
| loki.password | string | `""` | Optional Loki basic-auth password. Prefer existingSecret in production. |
| loki.tenantId | string | `"anonymous"` | Loki tenant ID (X-Scope-OrgID). |
| loki.user | string | `""` | Optional Loki basic-auth username. |
| lokiRules.affinity | object | `{}` | Affinity rules for the loki-rules sync Job. |
| lokiRules.backoffLimit | int | `2` | Job .spec.backoffLimit. |
| lokiRules.config.existingName | string | `""` | Use an existing ConfigMap/Secret instead of letting the chart create one. |
| lokiRules.config.type | string | `"none"` | One of: configmap, secret, none. |
| lokiRules.enabled | bool | `false` | Enable the Loki rules sync Job. |
| lokiRules.extraEnv | list | `[]` | Extra environment variables for the loki-rules sync Job. |
| lokiRules.extraVolumeMounts | list | `[]` | Extra volume mounts for the loki-rules sync Job. |
| lokiRules.extraVolumes | list | `[]` | Extra volumes for the loki-rules sync Job. |
| lokiRules.imagePullSecrets | list | `[]` | Image pull secrets for the loki-rules sync Job. |
| lokiRules.nodeSelector | object | `{}` | Node selector for the loki-rules sync Job. |
| lokiRules.resources | object | `{}` | Resource requests and limits for the loki-rules sync Job. |
| lokiRules.rules | object | `{}` | Loki rule files. Each map key becomes a file inside the generated ConfigMap/Secret. Used only when config.existingName is empty. |
| lokiRules.rulesPathInContainer | string | `"/loki-rules"` | Path inside the container where Loki rule files are mounted (passed to mal-sync as --rules.path). |
| lokiRules.syncTempDir | string | `""` | Optional temp dir used by mal-sync. |
| lokiRules.tolerations | list | `[]` | Tolerations for the loki-rules sync Job. |
| lokiRules.topologySpreadConstraints | list | `[]` | Topology spread constraints for the loki-rules sync Job. |
| lokiRules.ttlSecondsAfterFinished | int | `3600` | Job .spec.ttlSecondsAfterFinished. |
| mimir.address | string | `"http://mimir-distributed-nginx.mimir.svc.cluster.local:80"` | Mimir API endpoint. |
| mimir.existingSecret.key | string | `""` | Key inside the Secret that holds the password. |
| mimir.existingSecret.name | string | `""` | Name of an existing Secret containing the Mimir password. |
| mimir.password | string | `""` | Optional Mimir basic-auth password. Prefer existingSecret in production. |
| mimir.tenantId | string | `"anonymous"` | Mimir tenant ID (X-Scope-OrgID). |
| mimir.user | string | `""` | Optional Mimir basic-auth username. |
| nameOverride | string | `""` | Override the chart name (defaults to .Chart.Name). |
| namespaces.mimir | string | `"default"` | Mimir rules namespace (--rules.namespace for mimir-rules). |
| rbac.create | bool | `true` | Create namespace-scoped Role and RoleBinding granting read access to the ConfigMaps/Secrets this chart manages. Most users can leave this enabled. |
| rules.affinity | object | `{}` | Affinity rules for the rules sync Job. |
| rules.backoffLimit | int | `2` | Job .spec.backoffLimit. |
| rules.config.existingName | string | `""` | Use an existing ConfigMap/Secret instead of letting the chart create one. |
| rules.config.key | string | `"rules.yml"` | Key inside the ConfigMap/Secret that holds the rules (informational only when mounting a directory of files). |
| rules.config.type | string | `"secret"` | One of: configmap, secret, none. |
| rules.enabled | bool | `true` | Enable the Mimir rules sync Job. |
| rules.extraEnv | list | `[]` | Extra environment variables for the rules sync Job. |
| rules.extraVolumeMounts | list | `[]` | Extra volume mounts for the rules sync Job. |
| rules.extraVolumes | list | `[]` | Extra volumes for the rules sync Job. |
| rules.imagePullSecrets | list | `[]` | Image pull secrets for the rules sync Job. |
| rules.nodeSelector | object | `{}` | Node selector for the rules sync Job. |
| rules.resources | object | `{}` | Resource requests and limits for the rules sync Job. |
| rules.rules | object | `{}` | Prometheus rule files. Each map key becomes a file inside the generated ConfigMap/Secret. Used only when config.existingName is empty. |
| rules.rulesPath | string | `"/rules"` | Path inside the container where rule files are mounted (passed to mal-sync as --rules.path). |
| rules.syncTempDir | string | `""` | Optional temp dir used by mal-sync. |
| rules.tolerations | list | `[]` | Tolerations for the rules sync Job. |
| rules.topologySpreadConstraints | list | `[]` | Topology spread constraints for the rules sync Job. |
| rules.ttlSecondsAfterFinished | int | `3600` | Job .spec.ttlSecondsAfterFinished. |
| securityContext | object | `{}` | Pod-level securityContext applied to all Job pods (toYaml'd as-is). Use this for pod-scope fields like fsGroup, runAsUser, supplementalGroups, fsGroupChangePolicy. |
| serviceAccount.annotations | object | `{}` | Annotations to add to the ServiceAccount. |
| serviceAccount.create | bool | `true` | Create a dedicated ServiceAccount. |
| serviceAccount.name | string | `""` | Name of the ServiceAccount. If empty and create=true, a name is derived from the fullname template. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
