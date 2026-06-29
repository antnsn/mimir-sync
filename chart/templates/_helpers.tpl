{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mimir-sync.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mimir-sync.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Chart name + version label.
*/}}
{{- define "mimir-sync.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels.
*/}}
{{- define "mimir-sync.labels" -}}
helm.sh/chart: {{ include "mimir-sync.chart" . }}
{{ include "mimir-sync.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{/*
Selector labels.
*/}}
{{- define "mimir-sync.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mimir-sync.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
ServiceAccount name.
*/}}
{{- define "mimir-sync.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "mimir-sync.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Container image reference (repository:tag), tag defaulting to the chart appVersion.
*/}}
{{- define "mimir-sync.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
{{- end -}}

{{/*
Shared pod scheduling block for the sync Jobs. Call with a dict:
  (dict "ctx" . "feature" .Values.<feature>)
Include with `nindent 6` (the pod spec indent). securityContext is chart-global;
the remaining knobs are per-feature.
*/}}
{{- define "mimir-sync.podScheduling" -}}
serviceAccountName: {{ include "mimir-sync.serviceAccountName" .ctx }}
restartPolicy: OnFailure
automountServiceAccountToken: false
{{- with .ctx.Values.securityContext }}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .feature.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .feature.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .feature.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .feature.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .feature.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Mimir connection env vars shared by the alertmanager and rules Jobs.
Include with `nindent 12` (the container env list indent).
*/}}
{{- define "mimir-sync.mimirEnv" -}}
- name: MIMIR_ADDRESS
  value: {{ .Values.mimir.address | quote }}
- name: MIMIR_TENANT_ID
  value: {{ .Values.mimir.tenantId | quote }}
{{- if .Values.mimir.user }}
- name: MIMIR_USER
  value: {{ .Values.mimir.user | quote }}
{{- end }}
{{- if .Values.mimir.existingSecret.name }}
- name: MIMIR_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mimir.existingSecret.name }}
      key: {{ .Values.mimir.existingSecret.key }}
{{- else if .Values.mimir.password }}
- name: MIMIR_PASSWORD
  value: {{ .Values.mimir.password | quote }}
{{- end }}
{{- end -}}

{{/*
Resolved name of the Alertmanager config ConfigMap/Secret.
*/}}
{{- define "mimir-sync.alertmanagerConfigName" -}}
{{- if .Values.alertmanager.config.existingName -}}
{{- .Values.alertmanager.config.existingName -}}
{{- else -}}
{{- printf "%s-alertmanager-config" (include "mimir-sync.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Resolved name of the Mimir rules ConfigMap/Secret.
*/}}
{{- define "mimir-sync.rulesConfigName" -}}
{{- if .Values.rules.config.existingName -}}
{{- .Values.rules.config.existingName -}}
{{- else -}}
{{- printf "%s-rules-config" (include "mimir-sync.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Resolved name of the Loki rules ConfigMap/Secret.
*/}}
{{- define "mimir-sync.lokiRulesConfigName" -}}
{{- if .Values.lokiRules.config.existingName -}}
{{- .Values.lokiRules.config.existingName -}}
{{- else -}}
{{- printf "%s-loki-rules-config" (include "mimir-sync.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
