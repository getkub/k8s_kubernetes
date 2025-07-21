{{/*
Expand the name of the chart.
*/}}
{{- define "n8n-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "n8n-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "n8n-stack.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
