{{/*
Expand the name of the chart.
*/}}
{{- define "aks-rbac.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "aks-rbac.fullname" -}}
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
{{- define "aks-rbac.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "aks-rbac.labels" -}}
helm.sh/chart: {{ include "aks-rbac.chart" . }}
{{ include "aks-rbac.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "aks-rbac.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aks-rbac.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "aks-rbac.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "aks-rbac.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "aks-rbac.role.resources" -}}
["deployments", "replicasets", "pods", "statefulsets", "cronjobs", "jobs", "services", "persistentvolumeclaims", "events", "ingresses", "customresourcedefinitions","poddisruptionbudgets"]
{{- end -}}

{{- define "aks-rbac.role.rules" -}}
{{- if eq .Values.access "readonly" }}
- apiGroups: ["*"] # empty "" api group indicates the core API group
  resources: ["pods"]
  verbs: ["pods/logs"]
- apiGroups: [""] # empty "" api group indicates the core API group
  resources: ["namespaces"]
  verbs: ["get", "list"]
- apiGroups: ["*"] # empty "" api group indicates the core API group
  resources: {{ template "aks-rbac.role.resources" . }}
  verbs: ["get", "list", "watch"]
{{- end }}
{{- if eq .Values.access "write" }}
- apiGroups: ["*"] # empty "" api group indicates the core API group
  resources: ["pods"]
  verbs: ["pods/exec", "pods/logs"]
- apiGroups: [""] # empty "" api group indicates the core API group
  resources: ["namespaces"]
  verbs: ["get", "list"]
- apiGroups: ["*"] # empty "" api group indicates the core API group
  resources: {{ template "aks-rbac.role.resources" . }}
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
{{- end }}
{{- if eq .Values.access "full" }}
- apiGroups: ["*"] # empty "" api group indicates the core API group
  resources: ["*"]
  verbs: ["*"]
{{- end }}
{{- end }}