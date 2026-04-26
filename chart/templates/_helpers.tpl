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
