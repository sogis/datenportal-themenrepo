# datenportal-themenrepo

Dieses Repository ist die lokale Quelle fuer Organisationen, Datensaetze,
Pipeline-Defaults und moderne Gradle-Beispiele des Jenkins-Plugins
`jenkins-gretl-datenportal-plugin`.

## Aktueller Vertragsstand

Das Plugin verwendet ein festes Startformular. Unterstuetzt sind:

- `ORGANISATION`
- `DATASET`
- `METADATA_FILE`
- `DATA_FILE`
- `COMMENT`
- `SERIES_ID` nur bei Datensaetzen mit `"series": true`

Nicht mehr unterstuetzt sind:

- `gui`-Bloecke in YAML
- `dataset-gui.yaml`
- `ENVIRONMENT`
- `DRY_RUN`
- `CONFIRM_PRODUCTION`

## Inhalt

- `afu/` und `statistikdienst/` enthalten die v5-Demo-Organisationen.
- `shared/gretl-datenportal-defaults.yaml` enthaelt gemeinsame Defaults.
- `shared/Jenkinsfile` ist das repo-weite Default-Pipeline-Skript fuer
  Organisationen ohne eigenes `Jenkinsfile`.
- `shared/gradle/init.gradle` und `shared/gradle/organisation-common.gradle` enthalten die
  gemeinsame moderne Gradle-Build-Logik fuer GRETL-Plugins.
- `shared/gradle/gradle-build.properties` ist die gemeinsame Source of Truth fuer
  Plugin-Versionen, Repository-URLs und Offline-Seed-Koordinaten.

## Wie das Plugin dieses Repo verwendet

Das Plugin liest dieses Repository als fachliche Quelle fuer:

- Organisationen
- Datensaetze
- gemeinsame und organisationsspezifische Pipeline-Defaults

Erwartete Struktur:

```text
shared/
  gretl-datenportal-defaults.yaml
  Jenkinsfile
  gradle/
    gradle-build.properties
    init.gradle
    organisation-common.gradle
  data/
    offices.xtf

<organisation>/
  build.gradle
  gretl-datenportal-job.yaml
  Jenkinsfile                  # optional
  <dataset>/
    dataset.json
    dataset.gradle             # optional
```

### Bedeutung der Dateien

`shared/gretl-datenportal-defaults.yaml`

- Optionale repo-weite Defaults fuer mehrere Organisationen.
- Kann gemeinsame Werte wie `gradleTask`, `timeoutMinutes` und Notifications
  enthalten.

`shared/Jenkinsfile`

- Gemeinsames Default-Pipeline-Skript fuer alle Organisationen ohne
  spezifischere Jenkinsfile-Konfiguration.
- Greift nur, wenn weder `execution.jenkinsfile` noch ein
  organisationsspezifisches `Jenkinsfile` verwendet wird.

`shared/gradle/init.gradle`

- Zentrale Gradle-Initialisierung fuer Plugin- und Dependency-Repositories.
- Liest Plugin-Versionen und Repository-Listen aus
  `shared/gradle/gradle-build.properties`.
- Kann fuer Jenkins/Airgap auf ein vorbereitetes Offline-Jar-Bundle
  umgeschaltet werden.
- Default-Versionen:
  - `ch.so.agi.gretl` `5.0.0-SNAPSHOT`
  - `de.undercouch.download` `5.6.0`
  - `org.hidetake.ssh` `2.10.1`

`shared/gradle/gradle-build.properties`

- Kleine, explizite Source of Truth fuer:
  - moderne Plugin-Versionen
  - Online-Repositories
  - Seed-Koordinaten fuer den Offline-Bundle-Build
- Wird sowohl von `shared/gradle/init.gradle` als auch von
  `datenportal-jenkins-dev` verwendet.

### Maintainer: Repositories und Plugins pflegen

Diese beiden Dateien haben unterschiedliche Rollen und sollten als Paar gelesen
werden:

- [`shared/gradle/gradle-build.properties`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/gradle-build.properties)
  enthaelt die Daten: Plugin-IDs, Plugin-Versionen, Repository-URLs und die
  Artefakte, die ins Offline-Bundle muessen.
- [`shared/gradle/init.gradle`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/init.gradle)
  enthaelt die Logik: Online-/Offline-Aufloesung, `pluginManagement`,
  Default-Versionen fuer `plugins {}` und das Offline-Mapping von Plugin-ID auf
  Implementierungsmodul.
- Die organisationsspezifischen [`build.gradle`](#gradle-build-layout)-Dateien
  entscheiden, welches Plugin tatsaechlich verwendet wird. Ein Plugin kann
  zentral vorbereitet sein und trotzdem ungenutzt bleiben, solange es in keiner
  Organisation im `plugins {}`-Block aktiviert ist.

#### Zusaetzliches Maven-Repository hinzufuegen

Schritt 1. Entscheiden, ob das Repository fuer normale Artefakte, fuer
Plugin-Marker oder fuer beides gebraucht wird.

- `datenportal.repository.project.*` ist fuer normale Projekt- und
  Runtime-Artefakte.
- `datenportal.repository.plugin.*` ist fuer Plugin-Marker und
  `pluginManagement.repositories`.
- Wenn ein Repository sowohl Plugin-Marker als auch normale Artefakte liefert,
  muss es in beide Listen aufgenommen werden.
- Wenn ein Repository nur Runtime-Artefakte liefert, reicht
  `datenportal.repository.project.*`.

Schritt 2. Das Repository in
[`shared/gradle/gradle-build.properties`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/gradle-build.properties)
mit dem naechsten freien Index eintragen.

- Die Indizes muessen fortlaufend sein.
- Keine Luecken verwenden.
- Keine vorhandenen Nummern doppelt belegen.

Beispiel fuer ein neues Repository in beiden Listen:

```properties
datenportal.repository.project.7=https://repo.example.org/maven2/
datenportal.repository.plugin.7=https://repo.example.org/maven2/
```

Schritt 3. Bei `http://`-URLs nichts weiter in den Properties vermerken.

- [`shared/gradle/init.gradle`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/init.gradle:110)
  setzt `allowInsecureProtocol` automatisch fuer `http://`.
- Fuer `https://` ist keine Sonderbehandlung noetig.

Schritt 4. Verstehen, wie die Werte verwendet werden.

- Online liest `shared/gradle/init.gradle` die Listen aus
  `datenportal.repository.project.*` und `datenportal.repository.plugin.*`.
- Offline verwendet Gradle nicht mehr diese Remote-Repositories, sondern das
  vorbereitete Jar-Bundle via `DATENPORTAL_OFFLINE_JARS_DIR`.
- `datenportal-jenkins-dev` liest dieselben Repository-Listen beim Bau des
  Offline-Bundles, damit Online- und Offline-Aufloesung denselben Upstream
  haben.

Schritt 5. Verifizieren.

Online-Test:

```bash
cd /Users/stefan/sources/datenportal-themenrepo
./gradlew -I "$PWD/shared/gradle/init.gradle" -p afu tasks
```

Offline-Bundle neu bauen:

```bash
cd /Users/stefan/sources/datenportal-jenkins-dev
./bin/build-offline-bundle.sh
```

Offline-Test:

```bash
cd /Users/stefan/sources/datenportal-themenrepo
GRADLE_USER_HOME="/Users/stefan/sources/datenportal-jenkins-dev/build/offline-bundle/gradle-user-home" \
DATENPORTAL_OFFLINE_JARS_DIR="/Users/stefan/sources/datenportal-jenkins-dev/build/offline-bundle/jars" \
./gradlew --offline -I "$PWD/shared/gradle/init.gradle" -p statistikdienst verifyPluginSetup
```

#### Zusaetzliches Plugin hinzufuegen

Die folgende Anleitung zeigt das Prinzip fuer ein viertes Plugin. Als Beispiel
wird `com.github.ben-manes.versions` verwendet.

Schritt 1. Das Plugin technisch identifizieren.

- Plugin-ID: `com.github.ben-manes.versions`
- Plugin-Version: `0.52.0`
- Implementierungsmodul:
  `com.github.ben-manes:gradle-versions-plugin:0.52.0`

Schritt 2. Die neuen zentralen Werte in
[`shared/gradle/gradle-build.properties`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/gradle-build.properties)
ergaenzen.

Beispiel:

```properties
datenportal.plugin.versions.id=com.github.ben-manes.versions
datenportal.plugin.versions.version=0.52.0
datenportal.offline.seed.4=com.github.ben-manes:gradle-versions-plugin:0.52.0
```

Wenn das Plugin nur ueber ein neues Repository aufloesbar ist, muss dieses
zusaetzlich wie oben beschrieben in `datenportal.repository.project.*` und
gegebenenfalls `datenportal.repository.plugin.*` eingetragen werden.

Schritt 3. Das neue Plugin in
[`shared/gradle/init.gradle`](/Users/stefan/sources/datenportal-themenrepo/shared/gradle/init.gradle)
an drei Stellen ergaenzen.

1. Neue Default-Property lesen:

```groovy
def defaultVersionsPluginId = buildConfig.getProperty('datenportal.plugin.versions.id').toString().trim()
def defaultVersionsPluginVersion = buildConfig.getProperty('datenportal.plugin.versions.version').toString().trim()
```

2. Offline-Mapping in `resolutionStrategy` ergaenzen:

```groovy
if (requested.id.id == defaultVersionsPluginId) {
    useModule("com.github.ben-manes:gradle-versions-plugin:${defaultVersionsPluginVersion}")
}
```

3. Default-Version fuer `plugins {}` ergaenzen:

```groovy
id defaultVersionsPluginId version defaultVersionsPluginVersion
```

Schritt 4. Das Plugin in mindestens einer Organisation aktivieren.

Beispiel in [`afu/build.gradle`](/Users/stefan/sources/datenportal-themenrepo/afu/build.gradle:1):

```groovy
plugins {
    id 'ch.so.agi.gretl'
    id 'de.undercouch.download'
    id 'com.github.ben-manes.versions'
}
```

Ohne diesen Schritt ist das Plugin zwar zentral vorbereitet, aber nirgends im
Build aktiv.

Schritt 5. Das Offline-Bundle neu bauen.

```bash
cd /Users/stefan/sources/datenportal-jenkins-dev
./bin/build-offline-bundle.sh
```

Das Bundle muss neu gebaut werden, weil nur so das Implementierungsmodul und
seine transitiven Abhaengigkeiten in `build/offline-bundle/jars` landen.

Schritt 6. Verifizieren.

Online:

```bash
cd /Users/stefan/sources/datenportal-themenrepo
./gradlew -I "$PWD/shared/gradle/init.gradle" -p afu tasks
```

Offline:

```bash
cd /Users/stefan/sources/datenportal-themenrepo
GRADLE_USER_HOME="/Users/stefan/sources/datenportal-jenkins-dev/build/offline-bundle/gradle-user-home" \
DATENPORTAL_OFFLINE_JARS_DIR="/Users/stefan/sources/datenportal-jenkins-dev/build/offline-bundle/jars" \
./gradlew --offline -I "$PWD/shared/gradle/init.gradle" -p afu tasks
```

Wenn das Plugin eine eigene Task liefert, sollte zusaetzlich genau diese Task
aufgerufen oder zumindest via `tasks` sichtbar gemacht werden.

#### Wie finde ich das richtige Artefakt?

Fuer das Offline-Bundle ist nicht der Marker entscheidend, sondern das
Implementierungsmodul.

- Der Marker hat ueblicherweise einen Namen wie
  `<plugin-id>.gradle.plugin`.
- Das Implementierungsmodul ist das eigentliche Jar, das spaeter im
  Offline-Bundle landen muss.
- Das Implementierungsmodul steht im Marker-POM des Plugins oder ist im
  Plugin-Portal dokumentiert.

Beispiel `org.hidetake.ssh`:

- Marker:
  `org.hidetake.ssh:org.hidetake.ssh.gradle.plugin:2.10.1`
- Implementierung:
  `org.hidetake:gradle-ssh-plugin:2.10.1`

Darum steht im Offline-Seed heute das Implementierungsmodul und nicht der
Marker:

```properties
datenportal.offline.seed.3=org.hidetake:gradle-ssh-plugin:2.10.1
```

Dasselbe Prinzip gilt fuer jedes weitere Plugin.

#### Woher kommt GRETL wirklich?

Im aktuellen Setup kommt GRETL online nicht aus `mavenLocal()`.

- Online wird GRETL ueber die zentralen Repository-Listen aufgeloest.
- Fuer `gretl-core:5.0.0-SNAPSHOT` ist der primare Upstream
  `https://jars.interlis.guru/snapshots`.
- Offline kommt GRETL aus dem von `datenportal-jenkins-dev` gebauten
  Jar-Bundle unter `build/offline-bundle/jars`.

Wichtig fuer SNAPSHOTs:

- [`build-offline-bundle.sh`](/Users/stefan/sources/datenportal-jenkins-dev/bin/build-offline-bundle.sh)
  ruft Gradle mit `--refresh-dependencies` auf.
- Damit wird beim Bundle-Bau der aktuelle Stand eines SNAPSHOTs neu gegen die
  Remote-Repositories geprueft.
- Ohne diesen Refresh kann Gradle SNAPSHOTs aus dem Cache weiterverwenden.
- Wenn ein neuer GRETL-SNAPSHOT publiziert wurde, aber lokal noch nicht im
  Bundle sichtbar ist, zuerst das Offline-Bundle neu bauen.

`shared/gradle/organisation-common.gradle`

- Gemeinsame Build-Logik fuer alle Organisationen.
- Liest Jenkins-/Gradle-Parameter wie `dataset`, Upload-Dateipfade und optionale
  Zusatzparameter.
- Laedt optional ein dataset-spezifisches `dataset.gradle`.

`<organisation>/build.gradle`

- Duenner organisationsspezifischer Gradle-Wrapper fuer moderne GRETL-Plugins.
- Aktiviert die benoetigten Plugins mit `plugins {}`.
- Definiert nur organisationsspezifische Defaults und bindet dann die
  gemeinsame Build-Logik aus `../shared/gradle/organisation-common.gradle` ein.

`<organisation>/gretl-datenportal-job.yaml`

- Technisch zwingende Konfigurationsdatei pro Organisation.
- Ohne diese Datei ist der Organisationsordner kein gueltiger Plugin-Input und
  wird vom Plugin ignoriert.
- Steuert insbesondere Titel und Beschreibung des Jobs, Berechtigungen,
  Execution-Defaults und Notifications.
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

`<organisation>/<dataset>/dataset.gradle`

- Optionaler dataset-spezifischer Build-Override fuer die gemeinsame
  Organisations-Build-Logik.
- Wird nur geladen, wenn das Dataset zur Laufzeit via `-Pdataset=<id>`
  ausgewaehlt wurde.
- Eignet sich fuer dataset-spezifische Zusatz-Properties oder abweichende
  Build-Hinweise, nicht fuer Jenkins-Job-Generierung.

`<organisation>/Jenkinsfile`

- Optionales organisationsspezifisches Pipeline-Skript.
- Ueberschreibt das gemeinsame `shared/Jenkinsfile`.

### Prioritaeten und Overrides

Wichtig fuer `dataset.json`:

- `DATASET` wird aus den Datensatzordnern und deren `dataset.json` aufgebaut.
- In der UI erscheint der Datensatz als `title (id)`.
- Wenn `series: true` gesetzt ist, wird `SERIES_ID` sichtbar und fachlich
  erforderlich.
- Andere GUI-Anpassungen werden nicht mehr im Themenrepo definiert.

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

Build-Override-Kaskade:

```text
shared/gradle/init.gradle
-> shared/gradle/organisation-common.gradle
-> <organisation>/build.gradle
-> <organisation>/<dataset>/dataset.gradle
```

- Plugin-Versionen und Repositories werden zentral in
  `shared/gradle/gradle-build.properties` verwaltet.
- Jede Organisation bindet die gemeinsame Build-Logik per `apply from` ein.
- Dataset-spezifische Build-Anpassungen werden nur fuer das aktuell
  ausgewaehlte Dataset geladen.

### Gradle-Build-Layout

Die Jenkins-Pipelines fuehren den Gradle-Wrapper im Repo-Root aus und setzen
das jeweilige Organisationsverzeichnis als Projektpfad:

```bash
./gradlew -I "$PWD/shared/gradle/init.gradle" -p afu tasks
./gradlew -I "$PWD/shared/gradle/init.gradle" -p statistikdienst verifyPluginSetup
```

Wichtig:

- Es gibt **kein** globales `build.gradle` fuer alle Organisationen.
- Jede Organisation hat ihr eigenes `build.gradle`.
- Ein Datensatz bekommt bei Bedarf ein `dataset.gradle`, aber **kein**
  eigenes `build.gradle`.
- Die gemeinsame Logik liegt zentral in `shared/gradle/organisation-common.gradle`.
- Plugin-Versionen und Repository-URLs stehen zentral in
  `shared/gradle/gradle-build.properties`.

### Offline-Bundle und Airgap-Umschaltung

Die Herstellung des wiederverwendbaren Offline-Bundles gehoert bewusst nicht
mehr in dieses Repo, sondern nach `datenportal-jenkins-dev`.

`shared/gradle/init.gradle` unterstuetzt weiterhin die Umschaltung auf ein lokales
Offline-Bundle, das z. B. vom Jenkins-/Image-Repo vorbereitet wurde:

```bash
GRADLE_USER_HOME="$PWD/build/offline-bundle/gradle-user-home" \
DATENPORTAL_OFFLINE_JARS_DIR="$PWD/build/offline-bundle/jars" \
./gradlew \
  --offline \
  -I "$PWD/shared/gradle/init.gradle" \
  -p afu tasks
```

Alternativ kann `-PdatenportalOfflineJarsDir=/pfad/zum/jars` gesetzt
werden. Fuer die Gradle-Distribution muss im Offline-Fall zusaetzlich
`GRADLE_USER_HOME` auf das vorbereitete Bundle zeigen.

Mit gesetztem Offline-Jar-Verzeichnis verwendet Gradle die vorbereiteten Jars
fuer die Plugin- und Buildscript-Classpath-Resolution. Fuer harte
Netzwerksperren braucht es zusaetzlich eine Laufzeit-Sperre auf
Container-/Netzwerk-Ebene.

### Wie `./gradlew`, `GRADLE_USER_HOME` und Offline-Jars zusammenspielen

Im aktuellen Setup bleibt `./gradlew` der Startpunkt fuer Jenkins und lokale
Tests. Das Image installiert nicht einfach ein globales `gradle` und ersetzt
damit den Wrapper.

Der Ablauf ist stattdessen:

1. `shared/Jenkinsfile` wechselt ins ausgecheckte Themenrepo und startet
   `./gradlew`.
2. Der Wrapper liest `gradle/wrapper/gradle-wrapper.properties`.
3. Die dort konfigurierte Gradle-Distribution wird unter
   `GRADLE_USER_HOME/wrapper/dists` erwartet.
4. `datenportal-jenkins-dev` bereitet genau diesen Wrapper-Cache im
   Offline-Bundle vor.
5. `shared/gradle/init.gradle` bindet zusaetzlich die vorbereiteten Offline-Jars
   aus `DATENPORTAL_OFFLINE_JARS_DIR` fuer Buildscript- und Plugin-Aufloesung
   ein.

Damit gilt:

- `./gradlew` startet Gradle.
- `GRADLE_USER_HOME` liefert die passende Gradle-Distribution und Wrapper-Caches.
- `DATENPORTAL_OFFLINE_JARS_DIR` liefert die offline vorbereiteten Plugin- und
  Runtime-Jars.

Deshalb ist der Wrapper aktuell kein Zufall, sondern Teil des Vertrags zwischen
Themenrepo, `datenportal-jenkins-dev` und Jenkins-Image.

### Startformular

Das Plugin bringt ein Standardformular mit. Dazu gehoeren unter anderem:

- Upload-Felder fuer Metadaten und Daten
- `COMMENT`

Datensatz-spezifisch relevant ist:

- `DATASET` wird aus den vorhandenen Datensaetzen aufgebaut.
- `SERIES_ID` erscheint nur bei Datensaetzen mit `"series": true`.
- Weitere GUI-Felder koennen nicht mehr im Themenrepo definiert werden.

### Autoren-Checkliste

- Neue Organisation: Organisationsordner anlegen und
  `gretl-datenportal-job.yaml` pflegen.
- In jeder Organisation `permissions.read` und `permissions.build` explizit
  setzen.
- Pro Organisation ein `build.gradle` pflegen.
- Neuer Datensatz: eigener Datensatzordner plus `dataset.json`.
- Build-Overrides fuer einzelne Datensaetze nur ueber `dataset.gradle`.
- Gemeinsame Jenkins-/Repo-Defaults im `shared/`-Root pflegen, gemeinsame
  Gradle-Build-Logik unter `shared/gradle/` und Referenzdaten unter
  `shared/data/`.
- Nach Aenderungen den Seed-Job in Jenkins erneut ausfuehren.

## Maintainer-Workflows

### Neue Organisation anlegen

Minimum:

1. Organisationsordner anlegen, z. B. `neue-org/`.
2. `neue-org/gretl-datenportal-job.yaml` anlegen.
3. `neue-org/build.gradle` anlegen.
4. Mindestens einen Datensatzordner mit `dataset.json` anlegen.
5. Aenderungen committen.
6. In Jenkins den Seed-Job `gretl-datenportal-plugin-generator-local` erneut
   ausfuehren.

Pflicht fuer `gretl-datenportal-job.yaml`:

- `id` muss exakt dem Organisationsordner entsprechen.
- `permissions.read` muss gesetzt und nicht leer sein.
- `permissions.build` muss gesetzt und nicht leer sein.
- `gui` darf nicht verwendet werden.

Was automatisch passiert:

- Das Plugin scannt den Themenrepo nach Organisationen mit gueltigem
  `gretl-datenportal-job.yaml`.
- Fuer jede gueltige Organisation wird beim Seed ein Jenkins-Job erzeugt oder
  aktualisiert.
- Die Datensatz-Auswahl im Startformular wird aus den vorhandenen
  Datensatzordnern und deren `dataset.json` aufgebaut.
- Wenn `series: true` in `dataset.json` gesetzt ist, erscheint automatisch
  `SERIES_ID` im Startformular.

Was nicht automatisch passiert:

- Ohne erneuten Seed-Lauf taucht die neue Organisation in Jenkins nicht auf.
- Ohne `build.gradle` kann die Pipeline die Organisation nicht ausfuehren.
- Ohne gueltige Berechtigungen wird die Organisation vom Plugin als ungueltig
  behandelt.

### Neuen Datensatz zu bestehender Organisation hinzufuegen

Minimum:

1. Datensatzordner unter der Organisation anlegen.
2. `dataset.json` mit passender `id`, `title` und fachlichen Metadaten anlegen.
3. Optional `dataset.gradle` anlegen, wenn der Build datensatzspezifische
   Zusatzlogik braucht.
4. Aenderungen committen.
5. Den Seed-Job erneut ausfuehren.

Pflicht fuer `dataset.json`:

- `id` muss dem Datensatzordner entsprechen.
- `title` sollte gesetzt sein, weil er in der Datensatz-Auswahl angezeigt wird.
- `series: true` nur setzen, wenn das Startformular eine `SERIES_ID` verlangen
  soll.

Was automatisch passiert:

- Der Datensatz erscheint nach dem Seed im Startformular der Organisation.
- `DATASET` wird in der UI als `title (id)` angezeigt.
- `SERIES_ID` wird automatisch ein Pflichtfeld, wenn `series: true` gesetzt ist.

Was nicht automatisch passiert:

- Zusaeztliche GUI-Felder koennen nicht definiert werden.
- `dataset.gradle` erzeugt keinen eigenen Jenkins-Job und aendert keine
  Startformular-Felder; es wirkt nur waehrend des Gradle-Builds.

### Wann muss neu geseedet werden?

Ein erneuter Seed-Lauf ist immer noetig nach Aenderungen an:

- Organisationen oder Datensaetzen im Themenrepo
- `gretl-datenportal-job.yaml`
- `shared/gretl-datenportal-defaults.yaml`
- `shared/Jenkinsfile`
- dem Plugin selbst, wenn sich Scan-, Validierungs- oder Jobgenerator-Logik
  geaendert hat

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
