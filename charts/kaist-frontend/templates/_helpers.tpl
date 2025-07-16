{{/* Name related helpers */}}
{{- define "kaist-frontend.name" -}}
kaist-frontend
{{- end }}

{{- define "kaist-frontend.fullname" -}}
{{ .Release.Name }}-frontend
{{- end }}

