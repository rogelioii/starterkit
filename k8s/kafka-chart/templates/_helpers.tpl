{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka-chart.fullname" -}}
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
{{- define "kafka-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-chart.labels" -}}
helm.sh/chart: {{ include "kafka-chart.chart" . }}
{{ include "kafka-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafka-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafka-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create Kafka broker ID
*/}}
{{- define "kafka-chart.brokerId" -}}
{{- if eq (toString .Values.kafka.brokerId) "-1" }}
{{- printf "%d" (sub (int .Release.Revision) 1) }}
{{- else }}
{{- .Values.kafka.brokerId }}
{{- end }}
{{- end }}

{{/*
Create Kafka advertised listeners
*/}}
{{- define "kafka-chart.advertisedListeners" -}}
{{- if eq (int .Values.replicaCount) 1 -}}
PLAINTEXT://localhost:9092
{{- else -}}
{{- $fullname := include "kafka-chart.fullname" . -}}
{{- printf "PLAINTEXT://%s-headless.%s.svc.cluster.local:9092" $fullname (include "kafka-chart.namespace" .) -}}
{{- end -}}
{{- end }}

{{/*
Create namespace name
*/}}
{{- define "kafka-chart.namespace" -}}
{{- if .Values.namespace.create }}
{{- .Values.namespace.name }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}