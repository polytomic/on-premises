{{/*
Expand the name of the chart.
*/}}
{{- define "polytomic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "polytomic.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "polytomic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "polytomic.labels" -}}
helm.sh/chart: {{ include "polytomic.chart" . }}
{{ include "polytomic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "polytomic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Web Selector labels
*/}}
{{- define "polytomic.web-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-web
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Sync Selector labels
*/}}
{{- define "polytomic.sync-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-sync
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Worker Selector labels
*/}}
{{- define "polytomic.worker-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}




{{/*
Create the name of the service account to use
*/}}
{{- define "polytomic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "polytomic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Construct Polytomic Configuration
*/}}
{{- define "polytomic.config" -}}
ROOT_USER: {{ .Values.polytomic.auth.root_user | quote }}
DEPLOYMENT: {{ .Values.polytomic.deployment.name | quote }}
DEPLOYMENT_KEY: {{ .Values.polytomic.deployment.key | quote }}
{{ if .Values.polytomic.postgres.ssl -}}
DATABASE_URL: postgres://{{ .Values.polytomic.postgres.username }}{{- if .Values.polytomic.postgres.password}}:{{ .Values.polytomic.postgres.password }}{{- end}}@{{ .Values.polytomic.postgres.host }}:{{ .Values.polytomic.postgres.port }}/{{ .Values.polytomic.postgres.database }}
{{- else}}
DATABASE_URL: postgres://{{ .Values.polytomic.postgres.username }}{{- if .Values.polytomic.postgres.password}}:{{ .Values.polytomic.postgres.password }}{{- end}}@{{ .Values.polytomic.postgres.host }}:{{ .Values.polytomic.postgres.port }}/{{ .Values.polytomic.postgres.database }}?sslmode=disable
{{- end }}
{{ if .Values.polytomic.redis.ssl -}}
REDIS_URL: rediss://{{- if .Values.polytomic.redis.username}}{{ .Values.polytomic.redis.username }}{{- end}}{{- if .Values.polytomic.redis.password}}:{{ .Values.polytomic.redis.password }}{{- end}}{{- if or .Values.polytomic.redis.username  .Values.polytomic.redis.password}}@{{- end}}{{ .Values.polytomic.redis.host }}:{{ .Values.polytomic.redis.port }}/
{{- else}}
REDIS_URL: redis://{{- if .Values.polytomic.redis.username}}{{ .Values.polytomic.redis.username }}{{- end}}{{- if .Values.polytomic.redis.password}}:{{ .Values.polytomic.redis.password }}{{- end}}{{- if or .Values.polytomic.redis.username .Values.polytomic.redis.password}}@{{- end}}{{ .Values.polytomic.redis.host }}:{{ .Values.polytomic.redis.port }}/
{{- end }}
POLYTOMIC_URL: {{ .Values.polytomic.auth.url | quote }}
GOOGLE_CLIENT_ID: {{ .Values.polytomic.auth.google_client_id | quote }}
GOOGLE_CLIENT_SECRET: {{ .Values.polytomic.auth.google_client_secret | quote }}
EXECUTION_LOG_BUCKET: {{ .Values.polytomic.s3.log_bucket | quote }}
EXECUTION_LOG_REGION: {{ .Values.polytomic.s3.region| quote }}
EXPORT_QUERY_BUCKET: {{ .Values.polytomic.s3.query_bucket | quote }}
EXPORT_QUERY_REGION: {{ .Values.polytomic.s3.region | quote }}
LOG_LEVEL: {{ .Values.polytomic.log_level | quote }}
SINGLE_PLAYER: {{ .Values.polytomic.auth.single_player | quote }}
AIRTABLE_CLIENT_SECRET: "polytomic-GUE1aekik4MsgAEUhKyPCTaVUpxSM2KG"
AWS_REGION: {{ .Values.polytomic.s3.region | quote }}
AWS_ACCESS_KEY_ID: {{ .Values.polytomic.s3.access_key_id | quote }}
AWS_SECRET_ACCESS_KEY: {{ .Values.polytomic.s3.secret_access_key | quote }}

{{- end }}