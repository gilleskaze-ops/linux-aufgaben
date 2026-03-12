# Aufgabe: Umgebungsvariablen & Geheimnisse
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Sprache:** Python 3.12.3

---

## Teil 1 — Umgebungsvariablen

### Was sind Umgebungsvariablen?

Umgebungsvariablen sind Schlüssel-Wert-Paare, die außerhalb des Codes definiert werden und die Konfiguration einer Anwendung steuern. Sie ermöglichen es, denselben Code in verschiedenen Umgebungen (Entwicklung, Test, Produktion) mit unterschiedlichen Einstellungen zu betreiben — ohne den Code selbst zu ändern.

**Typische Anwendungsfälle:**
- Datenbank-Verbindungsstrings (`DATABASE_URL`)
- API-Endpunkte und Keys (`API_KEY`)
- Log-Level (`LOG_LEVEL=DEBUG` vs `LOG_LEVEL=ERROR`)
- Feature-Flags (`FEATURE_X_ENABLED=true`)
- Anwendungsname und Umgebung (`APP_NAME`, `ENV=production`)

---

### Praktisches Projekt: `app.py`

```python
import os

app_name = os.environ.get("APP_NAME", "DefaultApp")
greeting = os.environ.get("GREETING_MESSAGE", "Hallo Welt!")
db_url = os.environ.get("DATABASE_URL", "nicht gesetzt")

print(f"App: {app_name}")
print(f"Nachricht: {greeting}")
print(f"Datenbank: {db_url}")
```

**`os.environ.get("VAR", "default")`** → liest die Variable aus der Umgebung. Falls nicht gesetzt, wird der Standardwert verwendet.

---

### Ohne Umgebungsvariablen (Standardwerte)

```bash
python3 app.py
```

```
App: DefaultApp
Nachricht: Hallo Welt!
Datenbank: nicht gesetzt
```

---

### Mit Umgebungsvariablen (`export`)

```bash
export APP_NAME="MeinCloudProjekt"
export GREETING_MESSAGE="Willkommen in der Cloud!"
export DATABASE_URL="postgresql://localhost:5432/meinedb"
python3 app.py
```

```
App: MeinCloudProjekt
Nachricht: Willkommen in der Cloud!
Datenbank: postgresql://localhost:5432/meinedb
```

→ `export` definiert die Variable für die aktuelle Terminal-Session. Der Code bleibt unverändert.

---

### Dev vs. Produktion — gleicher Code, andere Konfiguration

**Produktionsmodus:**
```bash
export APP_NAME="MeinCloudProjekt-PROD"
export GREETING_MESSAGE="Willkommen in der Produktion!"
export DATABASE_URL="postgresql://prod-server:5432/proddb"
python3 app.py
```

```
App: MeinCloudProjekt-PROD
Nachricht: Willkommen in der Produktion!
Datenbank: postgresql://prod-server:5432/proddb
```

**Entwicklungsmodus:**
```bash
export APP_NAME="MeinCloudProjekt-DEV"
export GREETING_MESSAGE="Hallo Entwickler!"
export DATABASE_URL="postgresql://localhost:5432/devdb"
python3 app.py
```

```
App: MeinCloudProjekt-DEV
Nachricht: Hallo Entwickler!
Datenbank: postgresql://localhost:5432/devdb
```

→ Derselbe `app.py` — komplett unterschiedliches Verhalten durch Umgebungsvariablen.

**Variable entfernen:**
```bash
unset GREETING_MESSAGE
```

---

### Umgebungsvariablen unter verschiedenen Betriebssystemen

| Betriebssystem | Setzen | Auslesen |
|---|---|---|
| Linux / macOS | `export VAR="wert"` | `echo $VAR` |
| Windows (CMD) | `set VAR=wert` | `echo %VAR%` |
| Windows (PowerShell) | `$env:VAR="wert"` | `$env:VAR` |

---

## Teil 2 — Geheimnisse sicher verwalten

### Was unterscheidet Geheimnisse von normalen Variablen?

Normale Umgebungsvariablen konfigurieren das Verhalten einer Anwendung (`APP_NAME`, `LOG_LEVEL`). Geheimnisse sind sensible Daten, deren Kompromittierung direkte Sicherheitsfolgen hat:

| Typ | Beispiele |
|---|---|
| API-Schlüssel | AWS Access Keys, GitHub Tokens |
| Datenbank-Passwörter | `DB_PASSWORD=supergeheim` |
| Authentifizierungs-Tokens | JWT Secrets, OAuth Tokens |
| Zertifikate | TLS Private Keys |

**Risiken bei unsicherer Handhabung:**
- Secrets in Git commitet → öffentlich zugänglich für alle
- Bots scannen GitHub kontinuierlich nach exponierten Credentials
- Kompromittierter AWS Key → gesamtes Cloud-Konto gefährdet

---

### Lokale Lösung: `.env` Datei

```bash
# .env
APP_NAME="MeinCloudProjekt"
GREETING_MESSAGE="Willkommen!"
DATABASE_URL="postgresql://localhost:5432/meinedb"
API_KEY="mein-geheimer-api-key-12345"
DB_PASSWORD="supergeheimesPasswort!"
```

**Wichtig:** Diese Datei darf NIEMALS in Git commitet werden!

```bash
# .gitignore
.env
```

**Verifikation — Git ignoriert die Datei:**
```bash
git status
```

```
Unversionierte Dateien:
    .gitignore
    09032026/umgebungsvariablen/
```

→ `.env` erscheint nicht in der Liste — `.gitignore` funktioniert korrekt.
→ Die Datei existiert auf dem Datenträger, wird aber von Git vollständig ignoriert.

---

### Warum `.env` für die Produktion unzureichend ist

| Problem | Erklärung |
|---|---|
| Nicht skalierbar | `.env` liegt auf einer Maschine — bei 50 Servern nicht verwaltbar |
| Kein Audit Trail | Wer hat wann auf welches Secret zugegriffen? Unbekannt |
| Keine Rotation | Passwörter müssen manuell geändert werden |
| Sicherheitsrisiko | Bei Kompromittierung der Maschine sind alle Secrets exponiert |

---

### Professionelle Lösungen: Secret Management Services

| Service | Cloud | Funktion |
|---|---|---|
| **AWS Secrets Manager** | AWS | Zentrale Verwaltung, automatische Rotation, IAM-Integration |
| **HashiCorp Vault** | Multi-cloud | Open-source, sehr flexibel |
| **Azure Key Vault** | Azure | Zertifikate, Keys, Secrets |
| **GCP Secret Manager** | Google Cloud | Versionierte Secrets |

**Funktionsprinzip in AWS:**
1. Secret wird verschlüsselt in AWS Secrets Manager gespeichert
2. EC2/Lambda erhält eine IAM Role mit Leseberechtigung
3. Anwendung ruft das Secret zur Laufzeit ab — kein `.env` nötig
4. Zugriff wird geloggt (CloudTrail)
5. Automatische Rotation möglich

**Prinzipien:**
- **Least Privilege** → jede Anwendung bekommt nur Zugriff auf die Secrets, die sie braucht
- **Separation of Concerns** → Secrets werden getrennt vom Code verwaltet

---

## Zusammenfassung

| Konzept | Lokal | Produktion |
|---|---|---|
| Normale Variablen | `export VAR="wert"` | Umgebungsvariablen im Container/Server |
| Secrets (sicher) | `.env` + `.gitignore` | AWS Secrets Manager / Vault |
| Secrets (unsicher) | Hardcoded im Code ❌ | Niemals ❌ |

**Kernprinzip:** Code und Konfiguration sind immer getrennt. Secrets und Code sind immer getrennt.
