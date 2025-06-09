{{/*
Expand the name of the chart.
*/}}
{{- define "k3s_graphite_helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "k3s_graphite_helm.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- $name = regexReplaceAll "_" "-" $name -}}
{{- if .Values.fullnameOverride }}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
  {{- if .Values.namespace }}
    {{- printf "%s-%s" .Values.namespace $name | trunc 63 | trimSuffix "-" -}}
  {{- else }}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "k3s_graphite_helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k3s_graphite_helm.labels" -}}
helm.sh/chart: {{ include "k3s_graphite_helm.chart" . }}
{{ include "k3s_graphite_helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k3s_graphite_helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k3s_graphite_helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k3s_graphite_helm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k3s_graphite_helm.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
