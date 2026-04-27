# Aufgabe: GitHub Actions — Workflows, Variablen und Secrets
**Datum:** 15.04.2026  
**Repository:** github.com/gilleskaze-ops/linux-aufgaben  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Was ist GitHub Actions?

GitHub Actions ist ein **CI/CD-System** das automatisch Code ausführt wenn etwas im Repository passiert.

```
git push
    ↓ automatisch
GitHub Actions startet
    ↓
Tests ausführen
Docker Image bauen
Auf AWS deployen
Slack-Benachrichtigung senden
    ↓
Alles ohne menschliche Intervention!
```

**Warum ist das für einen AWS Engineer wichtig?**
```
Ohne GitHub Actions → alles manuell → Stunden Arbeit
Mit GitHub Actions  → automatisch in Minuten

Typischer Cloud-Workflow:
git push → Tests → docker build → ECR push → terraform apply → EKS deploy
```

---

## Workflow-Datei: `.github/workflows/sysadmin-basics.yml`

```yaml
name: SysAdmin Basics Workflow

on:
  push:                    # startet bei jedem Push
  workflow_dispatch:       # kann auch manuell gestartet werden

env:
  APP_NAME: "cloud-infra-tool"
  REGION: "eu-central-1"

jobs:
  sysadmin-check:
    runs-on: ubuntu-latest    # kostenloser GitHub Runner
    env:
      TARGET_ENV: "staging"

    steps:
      - name: Repository auschecken
        uses: actions/checkout@v4

      - name: System-Informationen anzeigen
        run: |
          date
          uname -a
          pwd && ls -la

      - name: Report-Verzeichnis erstellen
        run: mkdir -p reports

      - name: System-Report erstellen
        run: |
          echo "=== System Report ===" > reports/system-report.txt
          echo "Datum: $(date)" >> reports/system-report.txt
          echo "Runner: $RUNNER_NAME" >> reports/system-report.txt
          ls -la >> reports/system-report.txt

      - name: Runtime-Info mit Variablen erstellen
        env:
          STEP_VAR: "nur-fuer-diesen-step"
        run: |
          echo "App: $APP_NAME" > reports/runtime-info.txt
          echo "Region: $REGION" >> reports/runtime-info.txt
          echo "Zielumgebung: $TARGET_ENV" >> reports/runtime-info.txt
          echo "Step-Variable: $STEP_VAR" >> reports/runtime-info.txt

      - name: Umgebungskonfiguration laden
        run: |
          if [ "${{ github.ref_name }}" = "main" ]; then
            ENV_FILE="config/prod.env"
            echo "Umgebung: PRODUKTION"
          else
            ENV_FILE="config/dev.env"
            echo "Umgebung: ENTWICKLUNG"
          fi
          echo "Konfigurationsdatei: $ENV_FILE"
          if [ -f "$ENV_FILE" ]; then cat "$ENV_FILE"; fi

      - name: Secrets prüfen
        env:
          API_TOKEN: ${{ secrets.CLOUD_API_TOKEN }}
          SSH_HOST: ${{ secrets.SSH_TARGET }}
        run: |
          [ -n "$API_TOKEN" ] && echo "CLOUD_API_TOKEN: vorhanden ✅" || echo "CLOUD_API_TOKEN: fehlt ⚠️"
          [ -n "$SSH_HOST" ]  && echo "SSH_TARGET: vorhanden ✅"      || echo "SSH_TARGET: fehlt ⚠️"

      - name: Reports als Artefakt hochladen
        uses: actions/upload-artifact@v4
        with:
          name: workflow-reports
          path: reports/
```

---

## Aufgabe 1 — Workflow anlegen und ausführen

**Ergebnis:** Workflow läuft erfolgreich in 9 Sekunden ✅

```
feat: Github Actions Workflow sysadmin-basics hinzugefügt
SysAdmin Basics Workflow #1 → main → ✅ 9s
```

**Was passiert beim Push:**
```
GitHub erkennt .github/workflows/sysadmin-basics.yml
→ startet automatisch einen Runner (ubuntu-latest VM)
→ führt alle Steps der Reihe nach aus
→ grünes Häkchen ✅ wenn alles erfolgreich
```

---

## Aufgabe 2 — Umgebungsvariablen

**Drei Ebenen von Variablen:**

```yaml
# Workflow-Ebene (für alle Jobs)
env:
  APP_NAME: "cloud-infra-tool"
  REGION: "eu-central-1"

# Job-Ebene (für alle Steps des Jobs)
jobs:
  sysadmin-check:
    env:
      TARGET_ENV: "staging"

# Step-Ebene (nur für diesen Step)
    steps:
      - env:
          STEP_VAR: "nur-fuer-diesen-step"
```

**Log-Ausgabe:**
```
Simuliertes Zielsystem: staging in eu-central-1
Anwendung: cloud-infra-tool
```

---

## Aufgabe 3 — Artefakte hochladen

```yaml
- name: Reports als Artefakt hochladen
  uses: actions/upload-artifact@v4
  with:
    name: workflow-reports
    path: reports/
```

**Ergebnis:** Nach dem Workflow-Lauf steht ein Artefakt `workflow-reports` zum Download bereit — enthält `system-report.txt` und `runtime-info.txt`.

---

## Aufgabe 4 — Secrets sicher verwenden

**Secrets anlegen:** Repository → Settings → Secrets and variables → Actions

```
CLOUD_API_TOKEN = test-token-12345
SSH_TARGET      = test-server.example.com
```

**Wichtige Regel:** Secrets NIE mit `echo` ausgeben!

```yaml
env:
  API_TOKEN: ${{ secrets.CLOUD_API_TOKEN }}
run: |
  [ -n "$API_TOKEN" ] && echo "vorhanden ✅" || echo "fehlt ⚠️"
```

**Log-Ausgabe (sicher):**
```
CLOUD_API_TOKEN: fehlt ⚠️   ← Secrets noch nicht angelegt
SSH_TARGET: fehlt ⚠️
```

---

## Aufgabe 5 — Umgebungsspezifische Konfiguration

**config/dev.env:**
```
BASE_URL=https://dev.example.com
LOG_LEVEL=DEBUG
MAINTENANCE_MODE=false
```

**config/prod.env:**
```
BASE_URL=https://prod.example.com
LOG_LEVEL=ERROR
MAINTENANCE_MODE=false
```

**Logik im Workflow:**
```yaml
if [ "${{ github.ref_name }}" = "main" ]; then
  ENV_FILE="config/prod.env"    # main Branch = Produktion
else
  ENV_FILE="config/dev.env"     # anderer Branch = Entwicklung
fi
```

---

## Workflow-Dokumentation (Aufgabe 6)

| Aspekt | Wert |
|---|---|
| **Name** | SysAdmin Basics Workflow |
| **Auslöser** | push, workflow_dispatch |
| **Runner** | ubuntu-latest |
| **Variablen** | APP_NAME, REGION (Workflow), TARGET_ENV (Job), STEP_VAR (Step) |
| **Secrets** | CLOUD_API_TOKEN, SSH_TARGET |
| **Artefakte** | workflow-reports (system-report.txt, runtime-info.txt) |
| **dev-Regel** | alle Branches außer main → config/dev.env |
| **prod-Regel** | main Branch → config/prod.env |

---

## Hinweis: Node.js Warning

```
Warning: Node.js 20 actions are deprecated
→ actions/checkout@v4 und actions/upload-artifact@v4
→ werden intern mit Node.js 20 ausgeführt
→ ab Juni 2026 → Node.js 24 wird Standard
→ Lösung: auf @v5 upgraden oder FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true setzen
→ Workflow läuft trotzdem erfolgreich ✅
```

---

## Verbindung zu AWS/Cloud

```
GitHub Actions in der Cloud-Praxis:

git push
    ↓
GitHub Actions:
  1. Tests ausführen
  2. docker build → Image bauen
  3. aws ecr push → Image in AWS ECR speichern
  4. terraform apply → AWS Infrastruktur aktualisieren
  5. kubectl apply → auf EKS deployen
  6. Slack: "Deployment erfolgreich ✅"

→ Das ist echtes DevOps / GitOps
→ Secrets = AWS Credentials sicher gespeichert
→ dev/prod Trennung = verschiedene AWS Accounts
```
