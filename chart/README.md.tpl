# {{ .Chart.Name }}

{{ .Chart.Description | nindent 2 }}

{{- if .Chart.Homepage }}
**Homepage:** <{{ .Chart.Homepage }}>
{{- end }}

## TL;DR

```bash
helm repo add mimir-sync https://antnsn.github.io/mimir-sync
helm install my-release mimir-sync/{{ .Chart.Name }} --version {{ .Chart.Version }}
```

## Introduction

This chart deploys {{ .Chart.Name }} on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm repo add mimir-sync https://antnsn.github.io/mimir-sync
helm install my-release mimir-sync/{{ .Chart.Name }} --version {{ .Chart.Version }}
```

These commands deploy {{ .Chart.Name }} on the Kubernetes cluster with the default configuration.

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm delete my-release
```

## Configuration

The following table lists the configurable parameters of the {{ .Chart.Name }} chart and their default values.

{{- if .Values }}
## Values

### Global values

| Parameter | Description | Default |
|-----------|-------------|---------|
{{- range $key, $value := .Values }}
| `{{ $key }}` | {{ $value.description | default "" | nindent 0 }} | `{{ $value | toYaml | nindent 0 }}` |
{{- end }}
{{- end }}

## Maintainers

{{- range $index, $maintainer := .Chart.Maintainers }}
- {{ $maintainer.Name }} ({{ $maintainer.URL }})
{{- end }}

## Source Code

* <{{ .Chart.Source.0 }}>
