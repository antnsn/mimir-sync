{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mimir-sync.name" -}}
{{- default .Chart.Name .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mimir-sync.fullname" -}}
{{- if .Values.global.fullnameOverride -}}
{{- .Values.global.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.global.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mimir-sync.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
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
Selector labels
*/}}
{{- define "mimir-sync.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mimir-sync.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mimir-sync.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mimir-sync.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the alertmanager config
*/}}
{{- define "mimir-sync.alertmanagerConfigName" -}}
{{- if .Values.alertmanager.config.existingName -}}
{{- .Values.alertmanager.config.existingName -}}
{{- else -}}
{{- printf "%s-alertmanager-config" (include "mimir-sync.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the rules config
*/}}
{{- define "mimir-sync.rulesConfigName" -}}
{{- if .Values.rules.config.existingName -}}
{{- .Values.rules.config.existingName -}}
{{- else -}}
{{- printf "%s-rules-config" (include "mimir-sync.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
