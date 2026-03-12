# Aufgaben 09.03.2026: Secrets Management
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

---

## Was sind Geheimnisse (Secrets)?

Normale Umgebungsvariablen konfigurieren das Verhalten einer Anwendung (`APP_NAME`, `LOG_LEVEL`). Geheimnisse sind **sensible Daten**, deren Kompromittierung direkte Sicherheitsfolgen hat.

| Typ | Beispiele |
|---|---|
| API-Schlüssel | AWS Access Keys, GitHub Tokens |
| Datenbank-Passwörter | `DB_PASSWORD=supergeheim` |
| Authentifizierungs-Tokens | JWT Secrets, OAuth Tokens |
| Zertifikate | TLS Private Keys |

---

## Risiken bei unsicherer Handhabung

- Secrets in Git commitet → öffentlich für alle zugänglich
- Bots scannen GitHub kontinuierlich nach exponierten Credentials
- Kompromittierter AWS Key → gesamtes Cloud-Konto gefährdet
- Fehlende Nachvollziehbarkeit: wer hat wann auf was zugegriffen?

---

## Lokale Lösung: `.env` Datei

```bash
# .env
APP_NAME="MeinCloudProjekt"
GREETING_MESSAGE="Willkommen!"
DATABASE_URL="postgresql://localhost:5432/meinedb"
API_KEY="mein-geheimer-api-key-12345"
DB_PASSWORD="supergeheimesPasswort!"
```

Diese Datei wird **niemals** in Git commitet.

---

## `.gitignore` — Git ignoriert die Datei

```bash
# .gitignore
.env
```

**Verifikation:**
```bash
git status
```

```
Unversionierte Dateien:
    .gitignore
    09032026/umgebungsvariablen/
```

→ `.env` erscheint nicht in der Liste — Git ignoriert die Datei vollständig.
→ Die Datei existiert auf dem Datenträger, wird aber nie commitet.

---

## Warum `.env` für die Produktion unzureichend ist

| Problem | Erklärung |
|---|---|
| Nicht skalierbar | `.env` liegt auf einer Maschine — bei 50 Servern nicht verwaltbar |
| Kein Audit Trail | Wer hat wann auf welches Secret zugegriffen? Unbekannt |
| Keine Rotation | Passwörter müssen manuell geändert werden |
| Sicherheitsrisiko | Bei Kompromittierung der Maschine sind alle Secrets exponiert |

---

## Professionelle Lösungen: Secret Management Services

| Service | Cloud | Besonderheit |
|---|---|---|
| **AWS Secrets Manager** | AWS | Automatische Rotation, IAM-Integration |
| **HashiCorp Vault** | Multi-cloud | Open-source, sehr flexibel |
| **Azure Key Vault** | Azure | Zertifikate, Keys, Secrets |
| **GCP Secret Manager** | Google Cloud | Versionierte Secrets |

---

## Funktionsprinzip: AWS Secrets Manager

```
Anwendung (EC2/Lambda)
    ↓ "Gib mir das DB-Passwort"
AWS Secrets Manager
    ↓ prüft IAM Role
    ↓ gibt Secret zurück (verschlüsselt übertragen)
Anwendung nutzt Secret zur Laufzeit
```

1. Secret wird **verschlüsselt** in AWS Secrets Manager gespeichert
2. EC2/Lambda erhält eine **IAM Role** mit Leseberechtigung
3. Anwendung ruft das Secret zur **Laufzeit** ab — kein `.env` nötig
4. Jeder Zugriff wird **geloggt** (CloudTrail)
5. **Automatische Rotation** möglich

---

## Sicherheitsprinzipien

**Least Privilege** → Jede Anwendung bekommt nur Zugriff auf die Secrets, die sie wirklich braucht. Eine Lambda-Funktion für Benutzer-Authentifizierung bekommt keinen Zugriff auf DB-Backups.

**Separation of Concerns** → Secrets werden vollständig getrennt vom Code verwaltet. Der Entwickler schreibt Code, der Ops-Engineer verwaltet die Secrets. Keine Überschneidung.

---

## Zusammenfassung

| Methode | Umgebung | Sicherheit |
|---|---|---|
| Hardcoded im Code | ❌ Niemals | ❌ |
| `.env` ohne `.gitignore` | ❌ Niemals | ❌ |
| `.env` + `.gitignore` | Lokal / Entwicklung | ⚠️ Ausreichend lokal |
| AWS Secrets Manager / Vault | Produktion | ✅ |

**Kernprinzip:** Secrets und Code sind immer getrennt. In der Produktion werden Secrets niemals in Dateien gespeichert.
