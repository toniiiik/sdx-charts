{{/*
Expand the name of the chart.
*/}}
{{- define "cronjobs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cronjobs.fullname" -}}
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
{{- define "cronjobs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cronjobs.labels" -}}
helm.sh/chart: {{ include "cronjobs.chart" . }}
{{ include "cronjobs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cronjobs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cronjobs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cronjobs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cronjobs.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Renders a generic ordreder list (not for a directl use).
Usage:
  {{ include "cronjobs.tplvalues.render._list" (dict "use" SomeList "values" ValuesMap "context" $) }}
*/}}
{{- define "cronjobs.tplvalues._list" -}}
  {{- $items := list -}}

  {{- range $_, $name := .use | default list -}}
    {{- $value := get $.values $name -}}

    {{- if eq "string" (kindOf $value) -}}
      {{- $value = include "common.tplvalues.render" (dict "value" $value "context" $.context) -}}
    {{- end -}}

    {{- if eq "map" (kindOf $value) -}}
      {{- $value = dict "name" $name | merge $value -}}
    {{- else if and $value $.valueKey -}}
      {{- $value = ternary $value ($value | toString) (not $.toString) -}}
      {{- $value = dict "name" $name $.valueKey $value -}}
    {{- end -}}

    {{- if $value -}}
      {{- $items = append $items $value -}}
    {{- end -}}
  {{- end -}}

  {{- if $items -}}
    {{- include "common.tplvalues.render" (dict "value" $items "context" $.context) -}}
  {{- end -}}
{{- end -}}

{{/*
named-list renders a map as a list. The key list is alphabetically sorted, this maintains order for such kind of lists.
Such aproach is acceptable for env, ports lists, morover there are extra* parameters for lists such as extraEnvVars etc.
The extra parameters are true list and can be used as well.
Values example:
  env:
    HELLO: WORLD
    FOO: appears-in-the-list-before-HELLO
Usage:
  {{ include "cronjobs.tplvalues.render.named-list" ( dict "value" .Values.app.initContainer "context" $) }}
*/}}
{{- define "cronjobs.tplvalues.named-list" -}}
  {{- if kindIs "map" .value  -}}
    {{- include "cronjobs.tplvalues._list" (dict "use" (keys .value | sortAlpha) "values" .value "valueKey" .valueKey "toString" .toString "context" .context) -}}
  {{- end -}}
{{- end -}}