# Wahlresultate: Hop-Launcher-Pilot

Anwendungs-ID: `staatskanzlei.wahlresultate`. Der Katalog liegt unter
`../../shared/hop/applications.yaml`, die Formularbeschreibung neben `wahlresultate.hpl`.

Im Hop Application Launcher XML-Datei und Ausgabeordner auswählen, dann **Starten**.
Beide müssen ausserhalb des verwalteten Checkouts liegen. Die Datei wird auf Lesbarkeit
geprüft; die Pipeline wertet ihren Inhalt noch nicht aus. Sie schreibt eine UTF-8-CSV mit
Semikolon, Kopfzeile und einer Datenzeile (`message`, `input_file`).
**Eine vorhandene `hello-world.csv` im gewählten Ordner wird ersetzt.**

Die Pipeline verwendet Get Variables → Add Constants → Text File Output und die Parameter
`INPUT_XML` und `OUTPUT_DIR`. Für den direkten Start in Hop dieselben Parameter setzen;
`launcher-local` ist unter `shared/hop/metadata` versioniert.

Die Beispieldaten werden nicht mitversioniert. Diese Pilotanwendung richtet keine
Datenportal-/Jenkins-Publikation ein und ersetzt kein Datenblatt. Späteres eCH-0252-Mapping
wird in der Pipeline ergänzt, ohne fachliche Java-Logik im Launcher.
