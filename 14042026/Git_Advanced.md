# Aufgabe: Git-Workflow — Branches, Merge-Konflikte und Revert
**Datum:** 03.04.2026 / 14.04.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

> **Hinweis zur Umgebung:** Da das Arbeitsverzeichnis bereits ein Git-Repository (`linux-aufgaben`) war, wurde kein separates Bare-Repository angelegt. Der Git-Workflow mit Branches, Merge und Revert wurde direkt im bestehenden Repository praktisch durchgeführt — dies entspricht der realen Arbeitsweise.

---

## Projektstruktur

```
14042026/git-cloud-lab/
├── README.md
├── configs/
│   └── monitoring.conf
├── docs/
│   ├── runbook.md
│   └── merge-notes.md
└── scripts/
    └── deploy.sh
```

---

## Aufgabe 1 — Projektstruktur anlegen

```bash
mkdir -p 14042026/git-cloud-lab/{docs,scripts,configs}
```

**Dateien mit Inhalten:**

```bash
git add 14042026/
git commit -m "feat: git-cloud-lab Projectstruktur angelegt"
```

```
edd2f37 feat: git-cloud-lab Projectstruktur angelegt
```

---

## Aufgabe 2 — Feature-Branch anlegen

### Branch erstellen

```bash
git checkout -b feature/monitoring-update
```

### Änderungen auf dem Feature-Branch

**configs/monitoring.conf** — angepasst:
```
check_interval=30
alert_threshold=90
notify_email=admin@example.com
notify_slack=true
```

**docs/runbook.md** — Schritt hinzugefügt:
```
6. Monitoring-Alerts verifizieren
```

```bash
git add .
git commit -m "feat: monitoring-update - Intervall und Slack-Alert hinzugefügt"
```

### Git Graph nach Feature-Branch

```
* 580b3a6 (HEAD -> feature/monitoring-update) feat: monitoring-update
* edd2f37 (main) feat: git-cloud-lab Projectstruktur angelegt
```

**Wichtig:** main Branch bleibt unverändert — Feature-Branch isoliert ✅

---

## Aufgabe 3 — Parallele Änderung auf main simulieren

```bash
git checkout main
```

**configs/monitoring.conf** — anders geändert (Konflikt vorbereiten):
```
check_interval=120
alert_threshold=75
notify_email=ops-team@example.com
```

```bash
git add .
git commit -m "fix: monitoring-Schwellenwerte angepasst (main branch)"
```

### Git Graph — Divergenz sichtbar

```
* 4e6fdc4 (HEAD -> main) fix: monitoring-Schwellenwerte (main branch)
| * 580b3a6 (feature/monitoring-update) feat: monitoring-update
|/  
* edd2f37 gemeinsamer Ausgangspunkt
```

→ Beide Branches haben `monitoring.conf` unterschiedlich geändert → **Konflikt unvermeidlich!**

---

## Aufgabe 4 — Merge und Konflikt lösen

### Merge versuchen

```bash
git merge feature/monitoring-update
```

```
automatischer Merge von 14042026/git-cloud-lab/configs/monitoring.conf
KONFLIKT (Inhalt): Merge-Konflikt in configs/monitoring.conf
Automatischer Merge fehlgeschlagen
```

### Konfliktdatei analysieren

```bash
cat 14042026/git-cloud-lab/configs/monitoring.conf
```

```
<<<<<<< HEAD (main branch)
check_interval=120
alert_threshold=75
notify_email=ops-team@example.com
=======
check_interval=30
alert_threshold=90
notify_email=admin@example.com
notify_slack=true
>>>>>>> feature/monitoring-update
```

**Die Konfliktmarkierungen erklärt:**
```
<<<<<<< HEAD          → Inhalt aus dem aktuellen Branch (main)
=======               → Trennlinie
>>>>>>> feature/...   → Inhalt aus dem zu mergenden Branch
```

### Konflikt manuell lösen

**Entscheidung:** Bestes aus beiden Versionen kombinieren:
```
check_interval=30          ← Feature-Branch (häufigerer Check besser)
alert_threshold=75         ← main (konservativere Schwelle besser)
notify_email=ops-team@example.com  ← main (Team-E-Mail besser)
notify_slack=true          ← Feature-Branch (Slack-Benachrichtigung nützlich)
```

```bash
git add 14042026/git-cloud-lab/configs/monitoring.conf
git commit -m "merge: feature/monitoring-update - Konflikt manuell gelöst"
```

### Git Graph nach Merge

```
*   d434e2e (HEAD -> main) merge: Konflikt manuell gelöst
|\  
| * 580b3a6 (feature/monitoring-update) feat: monitoring-update
* | 4e6fdc4 fix: monitoring-Schwellenwerte (main)
|/  
* edd2f37 gemeinsamer Ausgangspunkt
```

→ Merge-Commit verbindet beide Entwicklungslinien ✅

---

## Aufgabe 5 — Fehlerhaften Commit mit git revert rückgängig machen

### Fehlerhaften Commit erstellen

```bash
echo "alert_threshold=999" >> 14042026/git-cloud-lab/configs/monitoring.conf
git add .
git commit -m "fix: FEHLER - falsche Schwelle gesetzt"
```

### Mit git revert rückgängig machen

```bash
git revert HEAD
# → Editor öffnet sich für Revert-Message → speichern
```

```
[main cb72b6b] Revert den Commit für die falsche Schwelle
1 file changed, 1 deletion(-)
```

### Git Log nach Revert

```
* cb72b6b (HEAD -> main) Revert den Commit für die falsche Schwelle
* 88566d3 fix: FEHLER - falsche Schwelle gesetzt  ← bleibt sichtbar!
*   d434e2e merge: feature/monitoring-update
```

---

## docs/merge-notes.md

### Merge-Konflikt Dokumentation

```
Betroffene Datei: configs/monitoring.conf

Ursache des Konflikts:
→ Beide Branches (main und feature/monitoring-update) haben
  dieselben Zeilen in monitoring.conf unterschiedlich geändert
→ Git kann nicht automatisch entscheiden welche Version korrekt ist

Gewählte Endfassung:
→ check_interval=30      (Feature-Branch: häufiger prüfen = besser)
→ alert_threshold=75     (main: konservativere Schwelle = sicherer)
→ notify_email=ops-team  (main: Team-E-Mail = professioneller)
→ notify_slack=true      (Feature-Branch: Slack-Alert = nützlich)
```

### git revert vs git reset

```
git revert:
→ Fügt einen NEUEN Commit hinzu der die Änderung rückgängig macht
→ Fehler-Commit bleibt in der Historie sichtbar (Transparenz!)
→ Sicher für geteilte/veröffentlichte Branches
→ Andere Entwickler verlieren keine History
→ EMPFOHLEN für shared Branches (main, develop)

git reset:
→ Löscht oder verschiebt Commits aus der Historie
→ Reschreibt die Git-History
→ GEFÄHRLICH auf geteilten Branches
  → andere Entwickler haben veraltete History → Probleme beim Push
→ Nur lokal verwenden, VOR dem Push
→ Anwendungsfall: lokale Experimente rückgängig machen
```

---

## Git-Workflow Zusammenfassung

```
1. Feature-Branch erstellen
   git checkout -b feature/mein-feature

2. Änderungen committen
   git add . && git commit -m "feat: ..."

3. Auf main mergen
   git checkout main
   git merge feature/mein-feature

4. Konflikte lösen (falls vorhanden)
   → Konfliktmarkierungen manuell bearbeiten
   → git add [datei] && git commit

5. Fehler rückgängig machen
   git revert HEAD    ← sicher, History bleibt
   (NICHT git reset auf shared branches!)

6. Branch aufräumen
   git branch -d feature/mein-feature
```

---

## Wichtige Befehle

```bash
git checkout -b branch-name     # neuen Branch erstellen und wechseln
git checkout main               # zu main wechseln
git merge branch-name           # Branch in aktuellen mergen
git log --oneline --graph --all # visueller Verlauf aller Branches
git revert HEAD                 # letzten Commit sicher rückgängig
git branch -d branch-name       # Branch löschen (nach Merge)
```

---

## Reflexion

**Merge-Konflikt — wichtigste Erkenntnis:**
```
→ Konflikte entstehen wenn zwei Branches DIESELBEN Zeilen ändern
→ Git kann nicht wissen welche Version "richtig" ist → menschliche Entscheidung
→ Konfliktmarkierungen zeigen genau was kollidiert
→ Immer fachlich sinnvolle Endfassung erstellen, nicht blind eine Seite wählen
```

**revert vs reset — die wichtigste Regel:**
```
Shared Branch (main, develop) → immer git revert
Lokale, unveröffentlichte Commits → git reset möglich

"Never rewrite public history" — Git Grundprinzip
```

**Verbindung zu Cloud/DevOps:**
```
→ Feature Branches = Standard in CI/CD Pipelines
→ Pull Requests auf GitHub/GitLab = kontrollierter Merge-Prozess
→ git revert = sicheres Rollback in Produktion
→ Terraform/Kubernetes Config in Git → gleiche Branching-Strategie
```
