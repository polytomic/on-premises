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
Schemacache Selector labels
*/}}
{{- define "polytomic.schemacache-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-schemacache
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Scheduler Selector labels
*/}}
{{- define "polytomic.scheduler-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-scheduler
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Jobworker Selector labels
*/}}
{{- define "polytomic.jobworker-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-jobworker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Healthcheck Selector labels
*/}}
{{- define "polytomic.healthcheck-selectorLabels" -}}
app.kubernetes.io/name: {{ include "polytomic.name" . }}-healthcheck
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
{{- else -}}
{{- .Values.externalPostgresql.host -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL port
*/}}
{{- define "polytomic.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
5432
{{- else -}}
{{- .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL username
*/}}
{{- define "polytomic.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username | default "polytomic" -}}
{{- else -}}
{{- .Values.externalPostgresql.username -}}
{{- end -}}
{{- end -}}

{{/*
Get PostgreSQL database name
*/}}
{{- define "polytomic.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | default "polytomic" -}}
{{- else -}}
{{- .Values.externalPostgresql.database -}}
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
{{- $password := "" -}}
{{- if .Values.postgresql.enabled -}}
{{- $sslMode = "disable" -}}
{{- $password = .Values.postgresql.auth.password | default "polytomic" -}}
{{- printf "postgres://%s:%s@%s:%s/%s?sslmode=%s"
    (include "polytomic.postgresql.username" .)
    $password
    (include "polytomic.postgresql.host" .)
    (include "polytomic.postgresql.port" .)
    (include "polytomic.postgresql.database" .)
    $sslMode -}}
{{- else -}}
{{- if .Values.externalPostgresql.sslMode -}}
{{- $sslMode = .Values.externalPostgresql.sslMode -}}
{{- else if .Values.externalPostgresql.ssl -}}
{{- $sslMode = "require" -}}
{{- end -}}
{{- printf "postgres://%s:%s@%s:%s/%s?sslmode=%s"
    (include "polytomic.postgresql.username" .)
    .Values.externalPostgresql.password
    (include "polytomic.postgresql.host" .)
    (include "polytomic.postgresql.port" .)
    (include "polytomic.postgresql.database" .)
    $sslMode -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis host
*/}}
{{- define "polytomic.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-redis-master" (include "polytomic.fullname" .) -}}
{{- else -}}
{{- .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{/*
Get Redis port
*/}}
{{- define "polytomic.redis.port" -}}
{{- if .Values.redis.enabled -}}
6379
{{- else -}}
{{- .Values.externalRedis.port -}}
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
{{- if $password -}}
{{- printf "redis://:%s@%s:%s"
    $password
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- else -}}
{{- printf "redis://%s:%s"
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- end -}}
{{- else -}}
{{- $password = .Values.externalRedis.password -}}
{{- if $password -}}
{{- if .Values.externalRedis.ssl -}}
{{- printf "rediss://:%s@%s:%s"
    $password
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- else -}}
{{- printf "redis://:%s@%s:%s"
    $password
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- end -}}
{{- else -}}
{{- printf "redis://%s:%s"
    (include "polytomic.redis.host" .)
    (include "polytomic.redis.port" .) -}}
{{- end -}}
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
DATABASE_PASSWORD: {{ .Values.externalPostgresql.password | quote }}
DATABASE_POOL_SIZE: {{ .Values.externalPostgresql.poolSize | default "15" | quote }}
DATABASE_IDLE_TIMEOUT: {{ .Values.externalPostgresql.idleTimeout | default "5s" | quote }}
{{- end }}
REDIS_URL: {{ include "polytomic.redis.url" . | quote }}
{{- if not .Values.redis.enabled }}
REDIS_PASSWORD: {{ .Values.externalRedis.password | quote }}
REDIS_POOL_SIZE: {{ .Values.externalRedis.poolSize | default "0" | quote }}
{{- end }}
POLYTOMIC_URL: {{ .Values.polytomic.auth.url | quote }}
AUTH_METHODS: {{ join "," .Values.polytomic.auth.methods | quote }}
GOOGLE_CLIENT_ID: {{ .Values.polytomic.auth.google_client_id | quote }}
GOOGLE_CLIENT_SECRET: {{ .Values.polytomic.auth.google_client_secret | quote }}
DEFAULT_OPERATIONAL_BUCKET: {{ .Values.polytomic.s3.operational_bucket }}{{- if .Values.polytomic.s3.region }}?region={{ .Values.polytomic.s3.region }}{{- end}}
LOG_LEVEL: {{ .Values.polytomic.log_level | quote }}
AUTO_MIGRATE: {{ if .Values.postgresql.enabled }}{{ true | quote }}{{ else }}{{ .Values.externalPostgresql.autoMigrate | default true | quote }}{{ end }}
DEFAULT_ORG_FEATURES: {{ join "," .Values.polytomic.default_org_features | quote }}
FIELD_CHANGE_TRACKING: {{ .Values.polytomic.field_change_tracking | quote }}
ENV: {{ .Values.polytomic.env | quote }}
SINGLE_PLAYER: {{ .Values.polytomic.auth.single_player | quote }}
AWS_REGION: {{ .Values.polytomic.s3.region | quote }}
AWS_ACCESS_KEY_ID: {{ .Values.polytomic.s3.access_key_id | quote }}
AWS_SECRET_ACCESS_KEY: {{ .Values.polytomic.s3.secret_access_key | quote }}
RECORD_LOG_BUCKET: {{ .Values.polytomic.s3.operational_bucket | trimPrefix "s3://" | quote }}
RECORD_LOG_REGION: {{ .Values.polytomic.s3.region | quote }}
EXECUTION_LOG_BUCKET: {{ .Values.polytomic.s3.operational_bucket | trimPrefix "s3://" | quote }}
EXECUTION_LOG_REGION: {{ .Values.polytomic.s3.region | quote }}
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
{{- if .Values.imagePullSecrets }}
KUBERNETES_IMAGE_PULL_SECRET: {{ (index .Values.imagePullSecrets 0).name | quote }}
{{- end }}
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
{{- with .Values.polytomic.roles }}
{{- with .task }}
TASK_EXECUTOR_CLEANUP_DELAY_SECONDS: {{ .cleanup_delay_seconds | quote }}
{{- if .cpu }}
TASK_EXECUTOR_CPU: {{ .cpu | quote }}
{{- end }}
{{- if .memory_reservation }}
TASK_EXECUTOR_MEMORY_RESERVATION: {{ .memory_reservation | quote }}
{{- end }}
{{- if .memory_maximum }}
TASK_EXECUTOR_MEMORY_MAXIMUM: {{ .memory_maximum | quote }}
{{- end }}
{{- if .memory_mega }}
TASK_EXECUTOR_MEMORY_MEGA: {{ .memory_mega | quote }}
{{- end }}
{{- if .database_pool_size }}
TASK_EXECUTOR_DATABASE_POOL_SIZE: {{ .database_pool_size | quote }}
{{- end }}
{{- if .redis_pool_size }}
TASK_EXECUTOR_REDIS_POOL_SIZE: {{ .redis_pool_size | quote }}
{{- end }}
{{- if .tags }}
TASK_EXECUTOR_TAGS: {{ .tags | quote }}
{{- end }}
{{- end }}
{{- with .bulk }}
{{- if .cleanup_delay_seconds }}
BULK_EXECUTOR_CLEANUP_DELAY_SECONDS: {{ .cleanup_delay_seconds | quote }}
{{- end }}
{{- if .cpu }}
BULK_EXECUTOR_CPU: {{ .cpu | quote }}
{{- end }}
{{- if .memory_reservation }}
BULK_EXECUTOR_MEMORY_RESERVATION: {{ .memory_reservation | quote }}
{{- end }}
{{- if .memory_maximum }}
BULK_EXECUTOR_MEMORY_MAXIMUM: {{ .memory_maximum | quote }}
{{- end }}
{{- if .memory_mega }}
BULK_EXECUTOR_MEMORY_MEGA: {{ .memory_mega | quote }}
{{- end }}
{{- if .database_pool_size }}
BULK_EXECUTOR_DATABASE_POOL_SIZE: {{ .database_pool_size | quote }}
{{- end }}
{{- if .redis_pool_size }}
BULK_EXECUTOR_REDIS_POOL_SIZE: {{ .redis_pool_size | quote }}
{{- end }}
{{- if .tags }}
BULK_TASK_EXECUTOR_TAGS: {{ .tags | quote }}
{{- end }}
{{- end }}
{{- with .ingest }}
{{- if .cleanup_delay_seconds }}
INGEST_EXECUTOR_CLEANUP_DELAY_SECONDS: {{ .cleanup_delay_seconds | quote }}
{{- end }}
{{- if .cpu }}
INGEST_EXECUTOR_CPU: {{ .cpu | quote }}
{{- end }}
{{- if .memory_reservation }}
INGEST_EXECUTOR_MEMORY_RESERVATION: {{ .memory_reservation | quote }}
{{- end }}
{{- if .memory_maximum }}
INGEST_EXECUTOR_MEMORY_MAXIMUM: {{ .memory_maximum | quote }}
{{- end }}
{{- if .memory_mega }}
INGEST_EXECUTOR_MEMORY_MEGA: {{ .memory_mega | quote }}
{{- end }}
{{- if .database_pool_size }}
INGEST_EXECUTOR_DATABASE_POOL_SIZE: {{ .database_pool_size | quote }}
{{- end }}
{{- if .redis_pool_size }}
INGEST_EXECUTOR_REDIS_POOL_SIZE: {{ .redis_pool_size | quote }}
{{- end }}
{{- if .tags }}
INGEST_TASK_EXECUTOR_TAGS: {{ .tags | quote }}
{{- end }}
{{- end }}
{{- with .proxy }}
{{- if .cleanup_delay_seconds }}
PROXY_EXECUTOR_CLEANUP_DELAY_SECONDS: {{ .cleanup_delay_seconds | quote }}
{{- end }}
{{- if .cpu }}
PROXY_EXECUTOR_CPU: {{ .cpu | quote }}
{{- end }}
{{- if .memory_reservation }}
PROXY_EXECUTOR_MEMORY_RESERVATION: {{ .memory_reservation | quote }}
{{- end }}
{{- if .memory_maximum }}
PROXY_EXECUTOR_MEMORY_MAXIMUM: {{ .memory_maximum | quote }}
{{- end }}
{{- if .memory_mega }}
PROXY_EXECUTOR_MEMORY_MEGA: {{ .memory_mega | quote }}
{{- end }}
{{- if .database_pool_size }}
PROXY_EXECUTOR_DATABASE_POOL_SIZE: {{ .database_pool_size | quote }}
{{- end }}
{{- if .redis_pool_size }}
PROXY_EXECUTOR_REDIS_POOL_SIZE: {{ .redis_pool_size | quote }}
{{- end }}
{{- if .tags }}
PROXY_TASK_EXECUTOR_TAGS: {{ .tags | quote }}
{{- end }}
{{- end }}
{{- with .scheduler }}
{{- if .cleanup_delay_seconds }}
SCHEDULER_ROLE_CLEANUP_DELAY_SECONDS: {{ .cleanup_delay_seconds | quote }}
{{- end }}
{{- if .cpu }}
SCHEDULER_ROLE_CPU: {{ .cpu | quote }}
{{- end }}
{{- if .memory_reservation }}
SCHEDULER_ROLE_MEMORY_RESERVATION: {{ .memory_reservation | quote }}
{{- end }}
{{- if .memory_maximum }}
SCHEDULER_ROLE_MEMORY_MAXIMUM: {{ .memory_maximum | quote }}
{{- end }}
{{- if .memory_mega }}
SCHEDULER_ROLE_MEMORY_MEGA: {{ .memory_mega | quote }}
{{- end }}
{{- if .database_pool_size }}
SCHEDULER_ROLE_DATABASE_POOL_SIZE: {{ .database_pool_size | quote }}
{{- end }}
{{- if .redis_pool_size }}
SCHEDULER_ROLE_REDIS_POOL_SIZE: {{ .redis_pool_size | quote }}
{{- end }}
{{- if .tags }}
SCHEDULER_TASK_EXECUTOR_TAGS: {{ .tags | quote }}
{{- end }}
{{- end }}
{{- end }}
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