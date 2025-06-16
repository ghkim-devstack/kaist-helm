{{- define "kaist-backend.name" -}}
kaist-backend
{{- end }}

{{- define "kaist-backend.fullname" -}}
{{ include "kaist-backend.name" . }}
{{- end }}

