{{/*
Validate that required values are provided
*/}}
{{- define "deploy-prefect.validateValues" -}}
{{- if not .Values.image.repository -}}
{{- required "image.repository is required" .Values.image.repository -}}
{{- end -}}

{{- if not .Values.image.tag -}}
{{- required "image.tag is required" .Values.image.tag -}}
{{- end -}}
{{- end -}}
