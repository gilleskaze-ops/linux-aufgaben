# Aufgaben 09.03.2026: Umgebungsvariablen & Bash-Skripting
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

---

## Teil 1 — Bash-Skripting: Systeminformationen

### Ausgangsskript (von Milan)

```bash
#!/bin/bash
dstpath=$HOME/projects/scripts
dstfile=result
date=$(date)
ipadress=$(hostname -I)
echo "$date" >> $dstpath/$dstfile
echo "$ipadress" >> $dstpath/$dstfile
```

**Problem beim ersten Test:**
```
./systeminfo.sh: Zeile 10: /home/dci-student/projects/scripts/result: Datei oder Verzeichnis nicht gefunden
```
→ Der Zielordner existierte nicht.

---

### Aufgabe 1 — Ordnerstruktur prüfen (`test` + `if`)

```bash
if [ ! -d "$dstpath" ]; then
    mkdir -p "$dstpath"
    echo "Ordner $dstpath wurde erstellt."
fi
```

- `[ ! -d "$dstpath" ]` → prüft ob Verzeichnis **nicht** existiert
- `mkdir -p` → erstellt Ordner inkl. übergeordneter Verzeichnisse

---

### Aufgabe 2 — Umgebungsvariablen ausgeben

```bash
echo "PWD  : $PWD"
echo "USER : $USER"
echo "HOME : $HOME"
```

**Output:**
```
PWD  : /home/dci-student/cloud/linux/09032026
USER : dci-student
HOME : /home/dci-student
```

Alle Umgebungsvariablen anzeigen: `printenv`

---

### Aufgabe 3 — Immer eine neue Datei erstellen

```bash
dstfile=result_$(date +%Y%m%d_%H%M%S)
```

**Ergebnis:**
```
result_20260312_094019
result_20260312_094027
result_20260312_100351
```

| Operator | Verhalten |
|---|---|
| `>` | Überschreibt die Datei |
| `>>` | Hängt an die Datei an |

---

### Aufgabe 4 — Distribution auslesen

```bash
distro=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
echo "$distro" >> $dstpath/$dstfile
```

→ `grep` findet die Zeile, `cut` extrahiert den Wert zwischen den Anführungszeichen.

---

### Aufgabe 5 — Ausgaben in `{}` bündeln

```bash
{
   echo "$date"
   echo "$ipadress"
   echo "$distro"
   echo "PWD  : $PWD"
   echo "USER : $USER"
   echo "HOME : $HOME"
} > $dstpath/$dstfile
```

→ Zieldatei wird nur einmal angegeben statt bei jedem `echo`.

---

### Fertiges Skript

```bash
#!/bin/bash
dstpath=$HOME/projects/scripts
dstfile=result_$(date +%Y%m%d_%H%M%S)

# Umgebungsvariablen im Terminal ausgeben
echo "PWD  : $PWD"
echo "USER : $USER"
echo "HOME : $HOME"

# Prüfen ob Ordner vorhanden ist
if [ ! -d "$dstpath" ]; then
    mkdir -p "$dstpath"
    echo "Ordner $dstpath wurde erstellt."
fi

# Systeminfos auslesen
date=$(date)
ipadress=$(hostname -I)
distro=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)

# Alle Infos gebündelt in Ausgabedatei schreiben
{
   echo "$date"
   echo "$ipadress"
   echo "$distro"
   echo "PWD  : $PWD"
   echo "USER : $USER"
   echo "HOME : $HOME"
} > $dstpath/$dstfile
```

**Inhalt der Ausgabedatei:**
```
Do 12. Mär 10:19:01 CET 2026
192.168.178.144 2003:f5:9740:8d00:...
Ubuntu 24.04.4 LTS
PWD  : /home/dci-student/cloud/linux/09032026
USER : dci-student
HOME : /home/dci-student
```

---

## Teil 2 — Umgebungsvariablen

### Was sind Umgebungsvariablen?

Umgebungsvariablen sind Schlüssel-Wert-Paare, die außerhalb des Codes definiert werden und die Konfiguration einer Anwendung steuern — ohne den Code zu ändern.

**Typische Anwendungsfälle:**
- Datenbank-Verbindungsstrings (`DATABASE_URL`)
- API-Endpunkte (`API_URL`)
- Log-Level (`LOG_LEVEL=DEBUG`)
- Feature-Flags (`FEATURE_X_ENABLED=true`)

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

---

### Ohne Umgebungsvariablen

```bash
python3 app.py
```
```
App: DefaultApp
Nachricht: Hallo Welt!
Datenbank: nicht gesetzt
```

---

### Mit Umgebungsvariablen

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

---

### Dev vs. Produktion — gleicher Code, andere Konfiguration

**Produktion:**
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

**Entwicklung:**
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

→ Derselbe Code — komplett unterschiedliches Verhalten.

---

### Umgebungsvariablen unter verschiedenen Betriebssystemen

| Betriebssystem | Setzen | Auslesen | Entfernen |
|---|---|---|---|
| Linux / macOS | `export VAR="wert"` | `echo $VAR` | `unset VAR` |
| Windows (CMD) | `set VAR=wert` | `echo %VAR%` | `set VAR=` |
| Windows (PowerShell) | `$env:VAR="wert"` | `$env:VAR` | `Remove-Item Env:VAR` |

---

## Zusammenfassung

| Aufgabe | Konzept | Status |
|---|---|---|
| Bash 1 | `if [ ! -d ]` + `mkdir -p` | ✅ |
| Bash 2 | `$PWD`, `$USER`, `$HOME` | ✅ |
| Bash 3 | Zeitstempel im Dateinamen | ✅ |
| Bash 4 | `grep` + `cut` auf `/etc/os-release` | ✅ |
| Bash 5 | `{}` Ausgaben bündeln | ✅ |
| Umgebungsvariablen | `export`, `unset`, dev vs prod | ✅ |
