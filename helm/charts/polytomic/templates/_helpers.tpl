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
vector.dev/include: "true"
{{- end }}

{{/*
Sync Selector labels
*/}}
{{- define "polytomic.sync-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-sync
app.kubernetes.io/instance: {{ .Release.Name }}
vector.dev/include: "true"
{{- end }}


{{/*
Worker Selector labels
*/}}
{{- define "polytomic.worker-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
vector.dev/include: "true"
{{- end }}


{{/*
Development Selector labels
*/}}
{{- define "polytomic.dev-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-dev
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
AUTH_METHODS: {{ join "," .Values.polytomic.auth.methods | quote }}
GOOGLE_CLIENT_ID: {{ .Values.polytomic.auth.google_client_id | quote }}
GOOGLE_CLIENT_SECRET: {{ .Values.polytomic.auth.google_client_secret | quote }}
EXECUTION_LOG_BUCKET: {{ .Values.polytomic.s3.log_bucket | quote }}
EXECUTION_LOG_REGION: {{ .Values.polytomic.s3.region| quote }}
DEFAULT_OPERATIONAL_BUCKET: {{ .Values.polytomic.s3.operational_bucket | quote }}
RECORD_LOG_BUCKET: {{ .Values.polytomic.s3.record_log_bucket | quote }}
RECORD_LOG_REGION: {{ .Values.polytomic.s3.region | quote }}
EXPORT_QUERY_BUCKET: {{ .Values.polytomic.s3.query_bucket | quote }}
EXPORT_QUERY_REGION: {{ .Values.polytomic.s3.region | quote }}
LOG_LEVEL: {{ .Values.polytomic.log_level | quote }}
AUTO_MIGRATE: {{ .Values.polytomic.postgres.auto_migrate | quote }}
DEFAULT_ORG_FEATURES: {{ join "," .Values.polytomic.default_org_features | quote }}
FIELD_CHANGE_TRACKING: {{ .Values.polytomic.field_change_tracking | quote }}
ENV: {{ .Values.polytomic.env | quote }}
SINGLE_PLAYER: {{ .Values.polytomic.auth.single_player | quote }}
AWS_REGION: {{ .Values.polytomic.s3.region | quote }}
AWS_ACCESS_KEY_ID: {{ .Values.polytomic.s3.access_key_id | quote }}
AWS_SECRET_ACCESS_KEY: {{ .Values.polytomic.s3.secret_access_key | quote }}
KUBERNETES: "true"
KUBERNETES_NAMESPACE: {{ .Release.Namespace | quote }}
KUBERNETES_IMAGE: {{ .Values.image.repository }}:{{ .Values.image.tag }}
KUBERNETES_VOLUME: {{ .Values.polytomic.cache.volume_name }}
KUBERNETES_SECRET: {{ include "polytomic.fullname" . }}-config
KUBERNETES_SERVICE_ACCOUNT: {{ include "polytomic.serviceAccountName" . | quote }}
AIRTABLE_CLIENT_SECRET: {{ .Values.polytomic.airtable_client_secret | quote }}
ASANA_CLIENT_ID: {{ .Values.polytomic.asana_client_id | quote }}
ASANA_CLIENT_SECRET: {{ .Values.polytomic.asana_client_secret | quote }}
BINGADS_CLIENT_ID: {{ .Values.polytomic.bingads_client_id | quote }}
BINGADS_CLIENT_SECRET: {{ .Values.polytomic.bingads_client_secret | quote }}
BINGADS_DEVELOPER_TOKEN: {{ .Values.polytomic.bingads_developer_token | quote }}
CCLOUD_API_KEY: {{ .Values.polytomic.ccloud_api_key | quote }}
CCLOUD_API_SECRET: {{ .Values.polytomic.ccloud_api_secret | quote }}
FBAUDIENCE_CLIENT_ID: {{ .Values.polytomic.fbaudience_client_id | quote }}
FBAUDIENCE_CLIENT_SECRET: {{ .Values.polytomic.fbaudience_client_secret | quote }}
FB_LOGIN_CONFIGURATION_ID: {{ .Values.polytomic.fb_login_configuration_id | quote }}
FRONT_CLIENT_ID: {{ .Values.polytomic.front_client_id | quote }}
FRONT_CLIENT_SECRET: {{ .Values.polytomic.front_client_secret | quote }}
GITHUB_CLIENT_ID: {{ .Values.polytomic.github_client_id | quote }}
GITHUB_CLIENT_SECRET: {{ .Values.polytomic.github_client_secret | quote }}
GITHUB_DEPLOY_KEY: {{ .Values.polytomic.github_deploy_key | quote }}
GOOGLEADS_CLIENT_ID: {{ .Values.polytomic.googleads_client_id | quote }}
GOOGLEADS_CLIENT_SECRET: {{ .Values.polytomic.googleads_client_secret | quote }}
GOOGLEADS_DEVELOPER_TOKEN: {{ .Values.polytomic.googleads_developer_token | quote }}
GOOGLESEARCHCONSOLE_CLIENT_ID: {{ .Values.polytomic.googlesearchconsole_client_id | quote }}
GOOGLESEARCHCONSOLE_CLIENT_SECRET: {{ .Values.polytomic.googlesearchconsole_client_secret | quote }}
GOOGLEWORKSPACE_CLIENT_ID: {{ .Values.polytomic.googleworkspace_client_id | quote }}
GOOGLEWORKSPACE_CLIENT_SECRET: {{ .Values.polytomic.googleworkspace_client_secret | quote }}
GSHEETS_API_KEY: {{ .Values.polytomic.gsheets_api_key | quote }}
GSHEETS_APP_ID: {{ .Values.polytomic.gsheets_app_id | quote }}
GSHEETS_CLIENT_ID: {{ .Values.polytomic.gsheets_client_id | quote }}
GSHEETS_CLIENT_SECRET: {{ .Values.polytomic.gsheets_client_secret | quote }}
HUBSPOT_CLIENT_ID: {{ .Values.polytomic.hubspot_client_id | quote }}
HUBSPOT_CLIENT_SECRET: {{ .Values.polytomic.hubspot_client_secret | quote }}
INTERCOM_CLIENT_ID: {{ .Values.polytomic.intercom_client_id | quote }}
INTERCOM_CLIENT_SECRET: {{ .Values.polytomic.intercom_client_secret | quote }}
LINKEDINADS_CLIENT_ID: {{ .Values.polytomic.linkedinads_client_id | quote }}
LINKEDINADS_CLIENT_SECRET: {{ .Values.polytomic.linkedinads_client_secret | quote }}
{{- if .Values.polytomic.cache.enabled }}
LOCAL_DATA: "1"
{{- else }}
LOCAL_DATA: "0"
{{- end }}
LOCAL_DATA_PATH: "/var/polytomic/"
METRICS: {{ .Values.polytomic.metrics | quote }}
OUTREACH_CLIENT_ID: {{ .Values.polytomic.outreach_client_id | quote }}
OUTREACH_CLIENT_SECRET: {{ .Values.polytomic.outreach_client_secret | quote }}
PARDOT_CLIENT_ID: {{ .Values.polytomic.pardot_client_id | quote }}
PARDOT_CLIENT_SECRET: {{ .Values.polytomic.pardot_client_secret | quote }}
QUERY_WORKERS: {{ .Values.polytomic.query_workers | quote }}
SALESFORCE_CLIENT_ID: {{ .Values.polytomic.salesforce_client_id | quote }}
SALESFORCE_CLIENT_SECRET: {{ .Values.polytomic.salesforce_client_secret | quote }}
SHIPBOB_CLIENT_ID: {{ .Values.polytomic.shipbob_client_id | quote }}
SHIPBOB_CLIENT_SECRET: {{ .Values.polytomic.shipbob_client_secret | quote }}
SHOPIFY_CLIENT_ID: {{ .Values.polytomic.shopify_client_id | quote }}
SHOPIFY_CLIENT_SECRET: {{ .Values.polytomic.shopify_client_secret | quote }}
SMARTSHEET_CLIENT_ID: {{ .Values.polytomic.smartsheet_client_id | quote }}
SMARTSHEET_CLIENT_SECRET: {{ .Values.polytomic.smartsheet_client_secret | quote }}
STRIPE_SECRET_KEY: {{ .Values.polytomic.stripe_secret_key | quote }}
SYNC_RETRY_ERRORS: {{ .Values.polytomic.sync_retry_errors | quote }}
SYNC_WORKERS: {{ .Values.polytomic.sync_workers | quote }}
TASK_EXECUTOR_CLEANUP_DELAY_SECONDS: {{ .Values.polytomic.task_executor_cleanup_delay_seconds | quote }}
TRACING: {{ .Values.polytomic.tracing | quote }}
TX_BUFFER_SIZE: {{ .Values.polytomic.tx_buffer_size | quote }}
WORKOS_API_KEY: {{ .Values.polytomic.auth.workos_api_key | quote }}
WORKOS_CLIENT_ID: {{ .Values.polytomic.auth.workos_client_id | quote }}
ZENDESK_CLIENT_ID: {{ .Values.polytomic.zendesk_client_id | quote }}
ZENDESK_CLIENT_SECRET: {{ .Values.polytomic.zendesk_client_secret | quote }}
hubspot_scopes_v2: "true"

{{- end }}