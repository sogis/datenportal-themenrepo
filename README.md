# datenportal-themenrepo

Dieses Repository ist die lokale Quelle fuer Organisationen, Datensaetze und
Pipeline-Defaults des Jenkins-Plugins
`jenkins-gretl-datenportal-plugin`.

## Inhalt

- `afu/` und `statistikdienst/` enthalten die v5-Demo-Organisationen.
- `shared/gretl-datenportal-defaults.yaml` enthaelt gemeinsame Defaults.
- `shared/Jenkinsfile` ist das repo-weite Default-Pipeline-Skript fuer
  Organisationen ohne eigenes `Jenkinsfile`.

## Lokale Entwicklung

Das lokale Jenkins-Setup in
`/Users/stefan/sources/datenportal-jenkins-dev` checkt dieses Repo per
`file:///Users/stefan/sources/datenportal-themenrepo` aus.

Wenn du hier neue Organisationen oder Datensaetze hinzufuegst:

1. Aenderungen committen.
2. In Jenkins den Job `gretl-datenportal-plugin-generator-local` erneut
   ausfuehren.
3. Danach stehen neue oder aktualisierte Jenkins-Jobs ohne Jenkins-Neustart
   zur Verfuegung.
