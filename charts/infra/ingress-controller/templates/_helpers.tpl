{{/*
Common labels
*/}}
{{- define "ingress-controller.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ingress-controller.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
