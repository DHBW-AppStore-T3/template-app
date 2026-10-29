# App-Entwickler-Anleitung (Vorlage für Pod-Apps)

Diese Vorlage zeigt, wie eine App für die Click-n-Deploy-Plattform als **Pods** läuft (App-Vertrag v2). Sie ist eine kleine nginx-App und dient als Ausgangspunkt für eigene Apps: Repository kopieren, Image und `appstore.yaml` anpassen, taggen, im AppStore einreichen.

---

## 1. Was ist eine App?

Eine App ist ein **Git-Repository** (GitHub) mit einer `appstore.yaml` und meist einem `image/`-Verzeichnis mit einem Dockerfile. Die Plattform erzeugt aus der `appstore.yaml` selbst alle Kubernetes-Objekte (eigener Namespace, Speicher, HTTPS-Link, Netzwerkregeln). Es läuft kein Code aus dem App-Repo auf der Plattform, und es ist kein OpenStack-Credential nötig.

Die Plattform deployt ausschließlich **versionierte Git-Tags**, keinen Branch.

## 2. Aufbau dieses Repositories

```
.
├── appstore.yaml                  # App-Vertrag v2: Container, Ressourcen, Speicher, Variablen, Zugänge
├── image/
│   ├── Dockerfile                 # das Image der App
│   ├── nginx.conf
│   └── site/index.html
└── .github/
    ├── workflows/ci.yml           # baut, prüft und veröffentlicht das Image (zentrale Pipeline aus app-registry)
    ├── workflows/spec.yml         # prüft appstore.yaml gegen den Vertrag, ohne zu bauen
    └── smoke-test.sh              # startet das Image im Sicherheitskontext der Plattform und prüft es
```

## 3. Von der Änderung zur Version

1. **Image bauen:** `.github/workflows/ci.yml` ruft die zentrale Pipeline aus `app-registry` auf (Vertrag, hadolint, Smoke-Test, Trivy) und veröffentlicht das Image nach `ghcr.io/dhbw-appstore-t3/apps/<app>`. Bei Pull Requests wird nur gebaut und geprüft. Das Image läuft als Nicht-Root mit schreibgeschütztem Dateisystem (`writablePaths` in der Spec für Verzeichnisse wie `/tmp`) und muss auch auf IPv6 (`[::]`) lauschen. Das GHCR-Paket muss öffentlich sein, damit die Plattform es ziehen kann.
2. **Digest eintragen:** Nach dem Build den Digest (`sha256:…`, steht in der Zusammenfassung des Workflow-Laufs) in `appstore.yaml` eintragen. Tags sind nicht erlaubt, nur Digests, und nur aus der erlaubten Registry. Ein Commit, der nur `appstore.yaml` ändert, löst keinen Build aus; ihn prüft `spec.yml`.
3. **Taggen:** eine neue Version im Format `v<Major>.<Minor>.<Patch>` taggen, z. B. `v2.0.1`. Tags in anderen Formaten sortieren nur lexikographisch und können im Wizard zur falschen „neueste Version“-Anzeige führen.
4. **Einreichen:** die Version im AppStore einreichen. Die Freigabe gilt für Commit, `appstore.yaml` und die Image-Digests.

## 4. Felder der `appstore.yaml`

Details: README von `appstore-api`, Abschnitt „Apps that run as pods“, und der Validator in `app-registry`.

- `scope`: `team` oder `user` (ein Workload je Team oder je Person)
- `workload.containers`: höchstens 3, genau einer mit `expose` (Port und Pfad; der Pfad ist die Ingress-Route, normalerweise `/`)
- `resources`: Limits und optional `requests`
- `env`: `generated-password`, `team-name`, `user-name` oder `value`
- `storage`: persistenter Speicher mit Größe und Einhängepfad
- `network`: `internet` und `podNetwork`, je `allowed` (Wahl im Wizard) und `default` (Startwert) 
- `variables`: `file`, `enum` oder `string`
- `access`: Link und Zugangsdaten, die unter „Meine Zugänge“ erscheinen

Unbekannte Felder werden abgelehnt.

---

## 5. App dem AppStore hinzufügen

### Push auf GitHub

Bevor die App gepusht wird, die `README.md` dieses Templates durch eine Beschreibung der eigenen App ersetzen (siehe „Pflichtangaben“ unten).

### Release / Git-Tag erstellen

Vor dem Hinzufügen der App im AppStore **muss** ein Release mit einem Git-Tag erstellt werden (Format siehe oben). Zu jedem Release gehört eine Beschreibung der Änderungen.

### App registrieren

Bei **privaten Repositories** muss zunächst der Collaborator `six7clickndeploy` hinzugefügt werden, damit der AppStore Zugriff hat: **Settings → Collaborators → Add people → `six7clickndeploy`**. Bei öffentlichen Repositories ist dieser Schritt nicht nötig.

Danach die **GitHub-URL des Repositories** im AppStore unter **„App hinzufügen“** eintragen:

```
https://github.com/<dein-username>/<repo-name>
```

Der AppStore liest die Tags und die `appstore.yaml` automatisch aus dem Repository ein.

### Pflichtangaben in der App-Beschreibung

Die README der App soll mindestens diese Punkte abdecken:

- **User-Management:** Wie melden sich Personen an? (z. B. ein Pod und ein Passwort je Person, gemeinsame Zugangsdaten je Team)
- **Deployment:** Ein Workload je Person oder je Team (`scope`)? Wie viel Speicher, Zugang zum Internet?
- **Konfigurierbare Variablen:** Was kann der Deployer einstellen, und wie wird es befüllt? (z. B. Datei-Upload, Auswahl)
- **Änderungen im Release:** Was wurde in dieser Version geändert oder hinzugefügt?

---

## Ältere Versionen

Die VM-Version dieser Vorlage (Terraform und Packer für OpenStack-VMs, ausführliche Entwickler-Anleitung dazu) wurde aus dem Repository entfernt. Sie bleibt in der Git-Historie vor `v2.0.0` abrufbar.
