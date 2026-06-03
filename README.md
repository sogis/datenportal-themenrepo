# datenportal-themenrepo

Dieses Repository ist die lokale Quelle fuer Organisationen, Datensaetze und
Pipeline-Defaults des Jenkins-Plugins
`jenkins-gretl-datenportal-plugin`.

## Inhalt

- `afu/` und `statistikdienst/` enthalten die v5-Demo-Organisationen.
- `shared/gretl-datenportal-defaults.yaml` enthaelt gemeinsame Defaults.
- `shared/Jenkinsfile` ist das repo-weite Default-Pipeline-Skript fuer
  Organisationen ohne eigenes `Jenkinsfile`.

## Wie das Plugin dieses Repo verwendet

Das Plugin liest dieses Repository als fachliche Quelle fuer:

- Organisationen
- Datensaetze
- GUI-Overrides fuer das Startformular
- gemeinsame und organisationsspezifische Pipeline-Defaults

Erwartete Struktur:

```text
shared/
  gretl-datenportal-defaults.yaml
  Jenkinsfile

<organisation>/
  gretl-datenportal-job.yaml
  Jenkinsfile                  # optional
  <dataset>/
    dataset.json
    dataset-gui.yaml           # optional
```

### Bedeutung der Dateien

`shared/gretl-datenportal-defaults.yaml`

- Optionale repo-weite Defaults fuer mehrere Organisationen.
- Kann gemeinsame Werte wie `gradleTask`, `timeoutMinutes`, Notifications und
  GUI-Feld-Overrides enthalten.

`shared/Jenkinsfile`

- Gemeinsames Default-Pipeline-Skript fuer alle Organisationen ohne
  spezifischere Jenkinsfile-Konfiguration.
- Greift nur, wenn weder `execution.jenkinsfile` noch ein
  organisationsspezifisches `Jenkinsfile` verwendet wird.

`<organisation>/gretl-datenportal-job.yaml`

- Technisch zwingende Konfigurationsdatei pro Organisation.
- Ohne diese Datei ist der Organisationsordner kein gueltiger Plugin-Input und
  wird vom Plugin ignoriert.
- Steuert insbesondere Titel und Beschreibung des Jobs, Berechtigungen,
  organisationsweite GUI-Overrides, Execution-Defaults und Notifications.
- Die `id` muss dem Namen des Organisationsordners entsprechen.
- `permissions.read` und `permissions.build` muessen beide vorhanden und nicht
  leer sein.

`<organisation>/<dataset>/dataset.json`

- Pflichtdatei pro Datensatz.
- Enthaelt die fachlichen Metadaten des Datensatzes.
- `id` muss dem Namen des Datensatzordners entsprechen.
- `title` wird in der Plugin-UI fuer die Datensatzwahl angezeigt.
- `description` ist die fachliche Beschreibung des Datensatzes.
- `series` steuert, ob im Startformular zusaetzlich ein Pflichtfeld
  `SERIES_ID` verlangt wird.
- `dataset.json` steuert keine GUI-Feldlabels, Uploadregeln oder
  Berechtigungen direkt.

`<organisation>/<dataset>/dataset-gui.yaml`

- Optionale Datensatz-spezifische GUI-Anpassung.
- Dient dazu, einzelne Formularfelder fuer genau einen Datensatz zu
  ueberschreiben oder zu ergaenzen.
- Es wird nur `gui.fields` ausgewertet.
- Zulaessig sind GUI-Eigenschaften wie `label`, `description`, `type`,
  `required`, `defaultValue`, `values`, `source`, `visibleIf`, `requiredIf`,
  `uploadMode`, `allowedExtensions` und `maxSizeMb`.
- Permissions, Execution, Notifications und fachliche Datensatzmetadaten werden
  hier nicht verarbeitet.

`<organisation>/Jenkinsfile`

- Optionales organisationsspezifisches Pipeline-Skript.
- Ueberschreibt das gemeinsame `shared/Jenkinsfile`.

### Prioritaeten und Overrides

GUI-Kaskade:

```text
Standard-GUI des Plugins
-> shared/gretl-datenportal-defaults.yaml
-> gretl-datenportal-job.yaml
-> dataset-gui.yaml
```

- GUI-Felder werden ueber ihre `id` zusammengefuehrt.
- Ein spaeteres Override kann Eigenschaften eines bestehenden Feldes
  ueberschreiben.
- Nicht ueberschriebene Felder bleiben erhalten.
- Neue Felder koennen ergaenzt werden.

Wichtig fuer `dataset.json`:

- `DATASET` wird aus den Datensatzordnern und deren `dataset.json` aufgebaut.
- In der UI erscheint der Datensatz als `title (id)`.
- Wenn `series: true` gesetzt ist, wird `SERIES_ID` sichtbar und fachlich
  erforderlich.
- Andere GUI-Anpassungen erfolgen nicht in `dataset.json`, sondern in
  `dataset-gui.yaml` oder ueber gemeinsame bzw. organisationsweite
  GUI-Overrides.

Execution- und Default-Logik:

- `gradleTask`, `timeoutMinutes` und Notifications koennen repo-weit in
  `shared/gretl-datenportal-defaults.yaml` gesetzt werden.
- Werte in `gretl-datenportal-job.yaml` ueberschreiben diese Defaults fuer die
  jeweilige Organisation.
- Fehlt `gretl-datenportal-job.yaml`, ist der gesamte Organisationsordner
  ungueltig und wird ignoriert.

Jenkinsfile-Aufloesung:

```text
execution.jenkinsfile
-> <organisation>/Jenkinsfile
-> shared-Pfad aus Defaults
-> shared/Jenkinsfile
```

- Falls `execution.jenkinsfile` gesetzt ist, wird dieser Pfad verwendet.
- Sonst greift ein `Jenkinsfile` im Organisationsordner.
- Sonst greift ein in den Shared-Defaults gesetzter Jenkinsfile-Pfad.
- Erst danach wird `shared/Jenkinsfile` als gemeinsamer Fallback verwendet.

### Startformular

Das Plugin bringt ein Standardformular mit. Dazu gehoeren unter anderem:

- `ENVIRONMENT`
- Upload-Felder fuer Metadaten und Daten
- `DRY_RUN`
- `COMMENT`
- `CONFIRM_PRODUCTION`

Datensatz-spezifisch relevant ist:

- `DATASET` wird aus den vorhandenen Datensaetzen aufgebaut.
- `SERIES_ID` erscheint nur bei Datensaetzen mit `"series": true`.
- Zuschnitt und Beschriftung weiterer GUI-Felder werden ueber die
  GUI-Overrides gesteuert, nicht ueber `dataset.json`.

### Autoren-Checkliste

- Neue Organisation: Organisationsordner anlegen und
  `gretl-datenportal-job.yaml` pflegen.
- In jeder Organisation `permissions.read` und `permissions.build` explizit
  setzen.
- Neuer Datensatz: eigener Datensatzordner plus `dataset.json`.
- GUI-Anpassungen fuer einzelne Datensaetze nur ueber `dataset-gui.yaml`.
- Gemeinsame Defaults und gemeinsames Pipeline-Verhalten unter `shared/`
  pflegen.
- Nach Aenderungen den Seed-Job in Jenkins erneut ausfuehren.

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
