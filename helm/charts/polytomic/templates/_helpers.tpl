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
Get PostgreSQL host
*/}}
{{- define "polytomic.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" (include "polytomic.fullname" .) -}}
{{- else if .Values.externalPostgresql.host -}}
{{- .Values.externalPostgresql.host -}}
{{- else -}}
{{- .Values.polytomic.postgres.host -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL port
*/}}
{{- define "polytomic.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
5432
{{- else if .Values.externalPostgresql.port -}}
{{- .Values.externalPostgresql.port -}}
{{- else -}}
{{- .Values.polytomic.postgres.port -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL username
*/}}
{{- define "polytomic.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username | default "polytomic" -}}
{{- else if .Values.externalPostgresql.username -}}
{{- .Values.externalPostgresql.username -}}
{{- else -}}
{{- .Values.polytomic.postgres.username -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL database name
*/}}
{{- define "polytomic.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | default "polytomic" -}}
{{- else if .Values.externalPostgresql.database -}}
{{- .Values.externalPostgresql.database -}}
{{- else -}}
{{- .Values.polytomic.postgres.database -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL password secret name
*/}}
{{- define "polytomic.postgresql.secretName" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-postgresql" (include "polytomic.fullname" .) -}}
{{- else if .Values.externalPostgresql.existingSecret.name -}}
{{- .Values.externalPostgresql.existingSecret.name -}}
{{- else -}}
{{- include "polytomic.fullname" . -}}-config
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL password secret key
*/}}
{{- define "polytomic.postgresql.secretKey" -}}
{{- if .Values.postgresql.enabled -}}
password
{{- else if .Values.externalPostgresql.existingSecret.name -}}
{{- .Values.externalPostgresql.existingSecret.key -}}
{{- else -}}
DATABASE_PASSWORD
{{- end -}}
{{- end -}}

{{/*
Build PostgreSQL connection URL
*/}}
{{- define "polytomic.postgresql.url" -}}
{{- $sslMode := "disable" -}}
{{- if .Values.postgresql.enabled -}}
{{- $sslMode = "disable" -}}
{{- else if .Values.externalPostgresql.sslMode -}}
{{- $sslMode = .Values.externalPostgresql.sslMode -}}
{{- else if .Values.externalPostgresql.ssl -}}
{{- $sslMode = "require" -}}
{{- else if .Values.polytomic.postgres.ssl -}}
{{- $sslMode = "require" -}}
{{- end -}}
{{- printf "postgres://%s:$(DATABASE_PASSWORD)@%s:%s/%s?sslmode=%s"
    (include "polytomic.postgresql.username" .)
    (include "polytomic.postgresql.host" .)
    (include "polytomic.postgresql.port" .)
    (include "polytomic.postgresql.database" .)
    $sslMode -}}
{{- end -}}

{{/*
Get Redis host
*/}}
{{- define "polytomic.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-redis-master" (include "polytomic.fullname" .) -}}
{{- else if .Values.externalRedis.host -}}
{{- .Values.externalRedis.host -}}
{{- else -}}
{{- .Values.polytomic.redis.host -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis port
*/}}
{{- define "polytomic.redis.port" -}}
{{- if .Values.redis.enabled -}}
6379
{{- else if .Values.externalRedis.port -}}
{{- .Values.externalRedis.port -}}
{{- else -}}
{{- .Values.polytomic.redis.port -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis password secret name
*/}}
{{- define "polytomic.redis.secretName" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-redis" (include "polytomic.fullname" .) -}}
{{- else if .Values.externalRedis.existingSecret.name -}}
{{- .Values.externalRedis.existingSecret.name -}}
{{- else -}}
{{- include "polytomic.fullname" . -}}-config
{{- end -}}
{{- end -}}

{{/*
Get Redis password secret key
*/}}
{{- define "polytomic.redis.secretKey" -}}
{{- if .Values.redis.enabled -}}
redis-password
{{- else if .Values.externalRedis.existingSecret.name -}}
{{- .Values.externalRedis.existingSecret.key -}}
{{- else -}}
REDIS_PASSWORD
{{- end -}}
{{- end -}}

{{/*
Build Redis connection URL
*/}}
{{- define "polytomic.redis.url" -}}
{{- $password := "" -}}
{{- if .Values.redis.enabled -}}
{{- $password = .Values.redis.auth.password -}}
{{- else if .Values.externalRedis.password -}}
{{- $password = .Values.externalRedis.password -}}
{{- else -}}
{{- $password = .Values.polytomic.redis.password -}}
{{- end -}}
{{- if $password -}}
{{- if or .Values.externalRedis.ssl .Values.polytomic.redis.ssl -}}
{{- printf "rediss://:$(REDIS_PASSWORD)@%s:%s"
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- else -}}
{{- printf "redis://:$(REDIS_PASSWORD)@%s:%s"
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- end -}}
{{- else -}}
{{- printf "redis://%s:%s"
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- end -}}
{{- end -}}

{{/*
Construct Polytomic Configuration
*/}}
{{- define "polytomic.config" -}}
ROOT_USER: {{ .Values.polytomic.auth.root_user | quote }}
DEPLOYMENT: {{ .Values.polytomic.deployment.name | quote }}
DEPLOYMENT_KEY: {{ .Values.polytomic.deployment.key | quote }}
DEPLOYMENT_API_KEY: {{ .Values.polytomic.deployment.api_key | quote }}
DATABASE_URL: {{ include "polytomic.postgresql.url" . | quote }}
{{- if not .Values.postgresql.enabled }}
{{- if .Values.externalPostgresql.password }}
DATABASE_PASSWORD: {{ .Values.externalPostgresql.password | quote }}
{{- else if .Values.polytomic.postgres.password }}
DATABASE_PASSWORD: {{ .Values.polytomic.postgres.password | quote }}
{{- end }}
DATABASE_POOL_SIZE: {{ .Values.externalPostgresql.poolSize | default "15" | quote }}
DATABASE_IDLE_TIMEOUT: {{ .Values.externalPostgresql.idleTimeout | default "5s" | quote }}
{{- end }}
REDIS_URL: {{ include "polytomic.redis.url" . | quote }}
{{- if not .Values.redis.enabled }}
{{- if .Values.externalRedis.password }}
REDIS_PASSWORD: {{ .Values.externalRedis.password | quote }}
{{- else if .Values.polytomic.redis.password }}
REDIS_PASSWORD: {{ .Values.polytomic.redis.password | quote }}
{{- end }}
REDIS_POOL_SIZE: {{ .Values.externalRedis.poolSize | default "0" | quote }}
{{- end }}
POLYTOMIC_URL: {{ .Values.polytomic.auth.url | quote }}
AUTH_METHODS: {{ join "," .Values.polytomic.auth.methods | quote }}
GOOGLE_CLIENT_ID: {{ .Values.polytomic.auth.google_client_id | quote }}
GOOGLE_CLIENT_SECRET: {{ .Values.polytomic.auth.google_client_secret | quote }}
EXECUTION_LOG_BUCKET: {{ .Values.polytomic.s3.record_log_bucket | quote }}
EXECUTION_LOG_REGION: {{ if .Values.polytomic.s3.gcs }}"gcs"{{- else }}{{ .Values.polytomic.s3.region | quote }}{{- end}}
DEFAULT_OPERATIONAL_BUCKET: {{ .Values.polytomic.s3.operational_bucket }}{{- if .Values.polytomic.s3.region }}?region={{ .Values.polytomic.s3.region }}{{- end}}
RECORD_LOG_BUCKET: {{ .Values.polytomic.s3.record_log_bucket | quote }}
RECORD_LOG_REGION: {{ .Values.polytomic.s3.region | quote }}
EXPORT_QUERY_BUCKET: {{ .Values.polytomic.s3.query_bucket | quote }}
EXPORT_QUERY_REGION: {{ .Values.polytomic.s3.region | quote }}
LOG_LEVEL: {{ .Values.polytomic.log_level | quote }}
{{- if .Values.postgresql.enabled }}
AUTO_MIGRATE: {{ .Values.polytomic.postgres.auto_migrate | default true | quote }}
{{- else }}
AUTO_MIGRATE: {{ .Values.externalPostgresql.autoMigrate | default true | quote }}
{{- end }}
DEFAULT_ORG_FEATURES: {{ join "," .Values.polytomic.default_org_features | quote }}
FIELD_CHANGE_TRACKING: {{ .Values.polytomic.field_change_tracking | quote }}
ENV: {{ .Values.polytomic.env | quote }}
SINGLE_PLAYER: {{ .Values.polytomic.auth.single_player | quote }}
AWS_REGION: {{ .Values.polytomic.s3.region | quote }}
AWS_ACCESS_KEY_ID: {{ .Values.polytomic.s3.access_key_id | quote }}
AWS_SECRET_ACCESS_KEY: {{ .Values.polytomic.s3.secret_access_key | quote }}
KUBERNETES: "true"
KUBERNETES_NAMESPACE: {{ .Release.Namespace | quote }}
KUBERNETES_IMAGE: {{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
KUBERNETES_VOLUME: {{ .Values.polytomic.sharedVolume.volumeName }}
{{- if .Values.secret.name }}
KUBERNETES_SECRET: {{ .Values.secret.name }}
{{- else }}
KUBERNETES_SECRET: {{ include "polytomic.fullname" . }}-config
{{- end }}
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
{{- if and .Values.polytomic.sharedVolume.enabled (ne .Values.polytomic.sharedVolume.mode "emptyDir") }}
LOCAL_DATA: "1"
{{- else }}
LOCAL_DATA: "0"
{{- end }}
LOCAL_DATA_PATH: {{ .Values.polytomic.sharedVolume.mountPath | quote }}
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
VERNEUIL_CONFIG: "{\"replication_spooling_dir\":\"/tmp/verneuil\",\"replication_targets\":[{\"s3\":{\"region\":\"{{ .Values.polytomic.s3.region }}\",\"chunk_bucket\":\"{{ .Values.polytomic.s3.operational_bucket }}/chunks\",\"manifest_bucket\":\"{{ .Values.polytomic.s3.operational_bucket }}/manifests\",\"create_buckets_on_demand\":false,\"domain_addressing\":false}}]}"
EXECUTION_LOGS_V2: {{ .Values.polytomic.internal_execution_logs | quote }}
INTERNAL_EXECUTION_LOGS: {{ .Values.polytomic.internal_execution_logs | quote }}

{{- if .Values.polytomic.s3.gcs }}
POLYTOMIC_USE_GCS: "true"
{{- end }}

{{- if .Values.polytomic.local }}
LOCAL: "true"
{{- end }}


{{- end }}