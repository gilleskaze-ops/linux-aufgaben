# Aufgabe: Bash-Skripting – Systeminformationen
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

---

## Ausgangsskript (von Milan)

```bash
#!/bin/bash
# Variablen definition
dstpath=$HOME/projects/scripts
dstfile=result
# Systeminfos auslesen
date=$(date)
ipadress=$(hostname -I)
echo "$date" >> $dstpath/$dstfile
echo "$ipadress" >> $dstpath/$dstfile
```

**Problem beim ersten Test:**
```
./systeminfo.sh: Zeile 10: /home/dci-student/projects/scripts/result: Datei oder Verzeichnis nicht gefunden
```
→ Der Zielordner existierte nicht. Dies führt direkt zu Aufgabe 1.

---

## Aufgabe 1 — Ordnerstruktur prüfen (`test` + `if`)

```bash
if [ ! -d "$dstpath" ]; then
    mkdir -p "$dstpath"
    echo "Ordner $dstpath wurde erstellt."
fi
```

**Erklärung:**
- `[ ! -d "$dstpath" ]` → prüft ob das Verzeichnis **nicht** existiert (`-d` = directory, `!` = nicht)
- `mkdir -p` → erstellt den Ordner inkl. aller übergeordneten Verzeichnisse
- Beim nächsten Lauf erscheint die Meldung nicht mehr — der `if`-Block wird übersprungen

**Output beim ersten Lauf:**
```
Ordner /home/dci-student/projects/scripts wurde erstellt.
```

---

## Aufgabe 2 — Umgebungsvariablen ausgeben

```bash
echo "PWD  : $PWD"
echo "USER : $USER"
echo "HOME : $HOME"
```

**Output im Terminal:**
```
PWD  : /home/dci-student/cloud/linux/09032026
USER : dci-student
HOME : /home/dci-student
```

**Hinweis:** Alle Umgebungsvariablen des Systems können mit `printenv` angezeigt werden.

---

## Aufgabe 3 — Immer eine neue Datei erstellen

```bash
# Alt (überschreibt oder ergänzt immer dieselbe Datei)
dstfile=result

# Neu (eindeutiger Dateiname mit Zeitstempel)
dstfile=result_$(date +%Y%m%d_%H%M%S)
```

**Ergebnis nach mehreren Ausführungen:**
```
result                      ← alte Datei
result_20260312_094019      ← 1. Ausführung
result_20260312_094027      ← 2. Ausführung
result_20260312_100351      ← 3. Ausführung
```

→ Jede Ausführung erzeugt eine neue, eindeutige Datei — kein Überschreiben, kein ungewolltes Anhängen.

**Unterschied `>` vs `>>`:**
| Operator | Verhalten |
|---|---|
| `>` | Überschreibt die Datei (oder erstellt sie neu) |
| `>>` | Hängt an die bestehende Datei an |

---

## Aufgabe 4 — Distribution aus `/etc/os-release` auslesen

```bash
distro=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
echo "$distro" >> $dstpath/$dstfile
```

**Erklärung:**
- `grep PRETTY_NAME /etc/os-release` → findet die Zeile `PRETTY_NAME="Ubuntu 24.04.4 LTS"`
- `cut -d '"' -f2` → schneidet den Wert zwischen den Anführungszeichen aus
- `$(...)` → speichert das Ergebnis in der Variable `distro`

**Output in der Ergebnisdatei:**
```
Ubuntu 24.04.4 LTS
```

---

## Aufgabe 5 — Alle Ausgaben in einem Block bündeln `{}`

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

**Vorteil:** Der Zieldateipfad `$dstpath/$dstfile` wird nur **einmal** angegeben statt bei jedem `echo`. Sauberer, wartbarer Code.

**Inhalt der Ausgabedatei:**
```
Do 12. Mär 10:19:01 CET 2026
192.168.178.144 2003:f5:9740:8d00:c5d4:5943:aec8:bef1 ...
Ubuntu 24.04.4 LTS
PWD  : /home/dci-student/cloud/linux/09032026
USER : dci-student
HOME : /home/dci-student
```

---

## Fertiges Skript

```bash
#!/bin/bash
dstpath=$HOME/projects/scripts
#dstfile=result
dstfile=result_$(date +%Y%m%d_%H%M%S)

# Umgebungsvariablen ausgeben
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

---

## Zusammenfassung

| Aufgabe | Konzept | Status |
|---|---|---|
| 1 | `if [ ! -d ]` + `mkdir -p` | ✅ |
| 2 | Umgebungsvariablen (`$PWD`, `$USER`, `$HOME`) | ✅ |
| 3 | Zeitstempel im Dateinamen (`date +%Y%m%d_%H%M%S`) | ✅ |
| 4 | `grep` + `cut` auf `/etc/os-release` | ✅ |
| 5 | Ausgaben in `{}` bündeln | ✅ |
