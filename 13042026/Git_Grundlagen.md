# Aufgabe: Git-Grundlagen mit lokalem Betriebsdoku-Repository
**Datum:** 02.04.2026 / 13.04.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

> **Hinweis:** `git init` wurde nicht neu ausgeführt, da das Repository `linux-aufgaben` bereits initialisiert war. Die Git-Grundlagen wurden direkt im bestehenden Repository praktisch angewendet — dies entspricht dem realen Arbeitsalltag, in dem man selten ein neues Repo initialisiert, sondern in bestehenden arbeitet.

---

## Die drei Zonen von Git

```
Working Directory  →  git add  →  Staging Area  →  git commit  →  Repository
(Dateien bearbeiten)             (Änderungen          (Snapshot
                                  vormerken)           speichern)
```

| Zone | Beschreibung | Befehl |
|---|---|---|
| Working Directory | Dateien auf der Festplatte | nano, vim, VS Code |
| Staging Area | Für nächsten Commit vorgemerkt | `git add` |
| Repository | Gespeicherte Commit-Historie | `git commit` |

---

## Aufgabe 1 — Repository anlegen

```
Hinweis: git init war bereits ausgeführt (linux-aufgaben Repository)
→ Projektordner direkt angelegt:
```

```bash
mkdir ~/cloud/linux/13042026/cloud-server-doku
cd ~/cloud/linux/13042026/cloud-server-doku
```

```bash
git status
# Auf Branch main
# Unversionierte Dateien:
#   13042026/
# → Git erkennt neuen Ordner als untracked
```

---

## Aufgabe 2 — Inhalte erfassen

### README.md
```markdown
# Cloud Server Dokumentation
Rolle: Web-Server (Produktion)
Beschreibung: nginx Webserver mit Monitoring
Verantwortlich: dci-student
Wartungsfenster: Sonntags 02:00-04:00 Uhr
```

### inventory.txt
```
Hostname: cloud-web-01
IP: 10.0.0.3
OS: Ubuntu 24.04 LTS
Region: eu-central-1
Umgebung: Produktion
Ansprechpartner: dci-student
```

### changes.md
```
## Änderungen
- 2026-04-02: Benutzer deploy angelegt
- 2026-04-02: System-Updates eingespielt
- 2026-04-02: Backup konfiguriert
```

---

## Aufgabe 3 — Gezielt zur Staging Area hinzufügen

### Schritt 1: Nur zwei Dateien stagen

```bash
git add 13042026/cloud-server-doku/README.md 13042026/cloud-server-doku/inventory.txt
git status
```

```
Zum Commit vorgemerkte Änderungen:
    neue Datei: 13042026/cloud-server-doku/README.md      ← staged ✅
    neue Datei: 13042026/cloud-server-doku/inventory.txt  ← staged ✅

Unversionierte Dateien:
    13042026/cloud-server-doku/changes.md                 ← noch nicht staged
```

### Schritt 2: Auch changes.md hinzufügen

```bash
git add 13042026/cloud-server-doku/changes.md
git status
# Alle drei Dateien → staged ✅
```

**Warum in zwei Schritten?**
```
→ Ermöglicht logisch getrennte Commits
→ z.B. Infrastruktur-Dateien separat von Änderungs-Log committen
→ Sauberere, nachvollziehbarere Git-Historie
```

---

## Aufgabe 4 — Ersten Commit erstellen

```bash
git commit -m "feat: initiale Cloud-Server-Dokumentation angelegt"
```

```bash
git status
# Ihr Branch ist vor 'origin/main' um 1 Commit.
# nichts zu committen, Arbeitsverzeichnis sauber ✅
```

**Commit-Message Konvention:**
```
feat:  → neue Funktion/Inhalt
fix:   → Fehlerbehebung
docs:  → Dokumentation
chore: → Wartungsaufgaben
```

---

## Aufgabe 5 — Zweiten Änderungszyklus

### maintenance.md anlegen

```bash
nano 13042026/cloud-server-doku/maintenance.md
```

```markdown
## Monatliche Wartungs-Checkliste
- [] Updates prüfen
- [] Speicherplatz kontrollieren
- [] Backup-Status prüfen
- [] Laufende Dienste kontrollieren
```

### Zweiter Commit

```bash
git add 13042026/cloud-server-doku/
git commit -m "feat: changes.md und Wartungs-Checklist hinzugefügt"
```

---

## Erweiterungsaufgabe 1 — Commit-Historie

```bash
git log --oneline
```

```
d89347f (HEAD -> main) fix: Wartungs-Checlist aktualisiert
9906922 feat: changes.md und Wartungs-Checklist hinzugefügt
ce08d0d feat: initiale Cloud-Server-Dokumentation angelegt
5493eef (origin/main) Aufgaben Docker Compose
...
```

---

## Erweiterungsaufgabe 2 — Änderungen vor Commit kontrollieren

### Änderung in maintenance.md

```bash
# CPU-Last prüfen hinzugefügt
nano 13042026/cloud-server-doku/maintenance.md
```

### git diff — Working Directory vs Staging

```bash
git diff 13042026/cloud-server-doku/maintenance.md
```

```diff
@@ -3,4 +3,5 @@
 - [] Speicherplatz kontrollieren
 - [] Backup-Status prüfen
 - [] Laufende Dienste kontrollieren
+- [] CPU-Last prüfen
```

### git diff --staged — Staging vs letzter Commit

```bash
git add 13042026/cloud-server-doku/maintenance.md
git diff --staged 13042026/cloud-server-doku/maintenance.md
```

```diff
+- [] CPU-Last prüfen
← zeigt genau was im nächsten Commit landet
```

```bash
git commit -m "fix: Wartungs-Checklist aktualisiert"
```

---

## Git-Kurzreferenz

| Befehl | Funktion | Beispiel |
|---|---|---|
| `git init` | Repository initialisieren | `git init` (einmalig) |
| `git status` | Zustand anzeigen | nach jeder Änderung |
| `git add` | Zur Staging Area hinzufügen | `git add README.md` |
| `git add .` | Alle Änderungen stagen | `git add .` |
| `git commit` | Snapshot speichern | `git commit -m "feat: ..."` |
| `git log --oneline` | Kompakte Historie | zeigt alle Commits |
| `git diff` | Änderungen im Working Dir | vor git add |
| `git diff --staged` | Änderungen in Staging | nach git add, vor commit |
| `git push` | Zum Remote pushen | `git push origin main` |

---

## Reflexion

**Die drei Zonen in der Praxis:**
```
Working Directory → ich bearbeite Dateien frei
Staging Area      → ich entscheide BEWUSST was in den nächsten Commit kommt
Repository        → unveränderliche Snapshots der Geschichte

→ git diff          zeigt: was habe ich geändert aber noch nicht gestaged?
→ git diff --staged zeigt: was kommt in meinen nächsten Commit?
→ git status        zeigt: wo stehe ich gerade?
```

**Git in der Cloud-Praxis:**
```
→ Terraform-Konfigurationen versionieren
→ Kubernetes YAML-Manifests tracken
→ Infrastructure as Code nachvollziehbar machen
→ Rollback möglich: git revert bei Fehlkonfiguration
→ Team-Zusammenarbeit: jeder sieht wer was wann geändert hat
```
