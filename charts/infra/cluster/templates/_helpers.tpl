{{/*
Common labels
*/}}
{{- define "personal-cluster.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "personal-cluster.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
