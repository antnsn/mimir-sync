{{- define "custom.usage" -}}
{{- if .Values.usage }}
{{ .Values.usage | nindent 4 }}
{{- else }}
```yaml
## Example Usage

```yaml
# values.yaml
{{ .Values | toYaml | indent 2 }}
```
{{- end }}
{{- end -}}

# {{ .Chart.Name }}

{{ .Chart.Description | nindent 2 }}

{{- if .Chart.Homepage }}
**Homepage:** <{{ .Chart.Homepage }}>
{{- end }}

## Installation

```bash
helm repo add mimir-sync https://antnsn.github.io/mimir-sync
helm install my-release mimir-sync/{{ .Chart.Name }} --version {{ .Chart.Version }}
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
{{- range $key, $value := .Values }}
| `{{ $key }}` | {{ $value.description | default "" }} | `{{ $value | toYaml }}` |
{{- end }}

## Maintainers

{{- range $index, $maintainer := .Chart.Maintainers }}
- {{ $maintainer.Name }} ({{ $maintainer.URL }})
{{- end }}
