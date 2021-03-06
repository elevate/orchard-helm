{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "orchard-cms.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orchard-cms.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "orchard-cms.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the password secret.
*/}}
{{- define "orchard-cms.postgresSecret" -}}
{{- if .Values.global.postgresql.existingSecret }}
    {{- printf "%s" .Values.global.postgresql.existingSecret -}}
{{- else if .Values.postgresql.existingSecret -}}
    {{- printf "%s" .Values.postgresql.existingSecret -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Get the environment variables for postgres db connection
*/}}
{{- define "orchard-cms.postgresEnv" -}}
- name: PGHOST
{{ if .Values.postgresql.service.host }}
  value: {{ .Values.postgresql.service.host }}
{{ else }}
  value: {{ .Release.Name }}-postgresql
{{- end -}}
- name: PGPORT
  value: !!string {{ .Values.postgresql.service.port }}
- name: PGDATABASE
  value: {{ .Values.global.postgresql.postgresqlDatabase }}
- name: PGUSER
  value: {{ .Values.global.postgresql.postgresqlUsername }}
- name: PGPASSWORD
{{ if .Values.global.postgresql.postgresqlPassword }}
  value: {{ .Values.global.postgresql.postgresqlPassword }}
{{ else }}
  valueFrom:
    secretKeyRef:
      name: {{ include "orchard-cms.postgresSecret" . }}
      key: postgresql-password
{{- end }}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "orchard-cms.imagePullSecrets" -}}
{{- if .Values.global }}
{{- if .Values.global.imagePullSecrets }}
imagePullSecrets:
{{- range .Values.global.imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- else if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end -}}
{{- end -}}
