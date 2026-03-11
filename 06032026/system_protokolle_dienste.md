# Aufgabe: Systemprotokolle & Dienstverwaltung
**Datum:** 06.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

---

## Teil 1 — Systemprotokolle (Logs)

### 1.1 Erkundung von `/var/log/`

```bash
ls /var/log/
```

**Output (Auszug):**
```
auth.log        dmesg       kern.log    syslog
apt             dpkg.log    nginx/      unattended-upgrades
cloud-init.log  fail2ban.log journal    wtmp
```

**Bedeutung wichtiger Log-Dateien:**

| Datei | Inhalt |
|---|---|
| `auth.log` | Authentifizierungsereignisse (SSH, sudo, Login) |
| `syslog` | Allgemeine Systemmeldungen |
| `kern.log` | Kernel-Meldungen |
| `dmesg` | Hardware-Erkennung beim Systemstart |
| `dpkg.log` | Paketinstallationen und -entfernungen |
| `fail2ban.log` | Automatisch gesperrte IP-Adressen |
| `nginx/` | Zugriffs- und Fehler-Logs des Webservers |

---

### 1.2 Log-Betrachtung mit `cat`, `less` und `tail -f`

#### `cat` — Vollständige Ausgabe
```bash
cat /var/log/dpkg.log | tail -20
```

**Output (Auszug):**
```
2026-03-11 13:25:59 status installed libpcre2-posix3:amd64 10.42-4ubuntu2.1
2026-03-11 13:26:29 status installed packettracer:amd64 9.0
2026-03-11 13:26:30 status installed libc-bin:amd64 2.39-0ubuntu8.7
```

→ `cat` eignet sich für kleine Dateien. Bei großen Dateien wird die Ausgabe unübersichtlich.

#### `less` — Seitenweise Navigation
```bash
less /var/log/syslog
```

Navigation:
- `Space` / `f` → nächste Seite
- `b` → vorherige Seite
- `/suchbegriff` → Suche im Dokument
- `q` → beenden

→ `less` ist ideal für große Dateien — man kann vorwärts, rückwärts navigieren und nach Begriffen suchen.

#### `tail -f` — Echtzeit-Überwachung
```bash
sudo tail -f /var/log/auth.log
```

**Output während einer SSH-Verbindung von gikaze@ubuntu zum ThinkPad:**
```
2026-03-11T14:26:25 ThinkPad-L15 sshd[29131]: Accepted password for dci-student from 192.168.178.133 port 56832 ssh2
2026-03-11T14:26:25 ThinkPad-L15 sshd[29131]: pam_unix(sshd:session): session opened for user dci-student
2026-03-11T14:26:25 ThinkPad-L15 systemd-logind[874]: New session 75 of user dci-student.
```

→ `tail -f` zeigt neue Log-Einträge in Echtzeit — unverzichtbar für die Live-Überwachung eines Systems.

**Beobachtung:** Auch `sudo`-Befehle werden vollständig geloggt:
```
sudo: dci-student : TTY=pts/1 ; PWD=/home/dci-student/cloud/linux/06032026 ; USER=root ; COMMAND=/usr/bin/tail -f /var/log/auth.log
```
→ Jeder privilegierte Zugriff wird mit Benutzer, Verzeichnis und Befehl protokolliert.

---

**Vergleich der Tools:**

| Tool | Einsatz |
|---|---|
| `cat` | Kleine Dateien, schnelle Übersicht |
| `less` | Große Dateien, Navigation und Suche |
| `tail -f` | Echtzeit-Überwachung laufender Systeme |

---

### 1.3 `journalctl` — Systemd Journal

```bash
journalctl -u ssh --since "1 hour ago"
```

**Output:**
```
Mär 11 14:20:12 ThinkPad-L15 systemd[1]: Starting ssh.service - OpenBSD Secure Shell server...
Mär 11 14:20:12 ThinkPad-L15 sshd[28989]: Server listening on 0.0.0.0 port 22.
Mär 11 14:20:12 ThinkPad-L15 sshd[28989]: Server listening on :: port 22.
Mär 11 14:20:12 ThinkPad-L15 systemd[1]: Started ssh.service - OpenBSD Secure Shell server.
Mär 11 14:26:25 ThinkPad-L15 sshd[29131]: Accepted password for dci-student from 192.168.178.133
```

**Nützliche `journalctl`-Optionen:**

```bash
journalctl -u ssh               # Logs eines bestimmten Dienstes
journalctl -u ssh -f            # Echtzeit (wie tail -f)
journalctl --since "1 hour ago" # Ab einem bestimmten Zeitpunkt
journalctl --since "yesterday"  # Seit gestern
journalctl -p err               # Nur Fehlermeldungen
journalctl -p warning           # Warnungen und schwerwiegendere Meldungen
```

**Vorteil gegenüber klassischen Log-Dateien:**
- Strukturierte, durchsuchbare Datenbank statt reiner Textdateien
- Einfache Filterung nach Dienst, Zeit und Priorität
- Kein `grep` nötig für grundlegende Suchen

---

## Teil 2 — Dienstverwaltung mit `systemctl`

### 2.1 Überblick laufender Dienste

```bash
systemctl list-units --type=service --state=running
```

→ 35 aktive Dienste, darunter: `ssh`, `nginx`, `cron`, `fail2ban`, `NetworkManager`, `docker`

---

### 2.2 Dienststatus überprüfen

```bash
systemctl status ssh
systemctl status cron
systemctl status systemd-timesyncd
```

**Ergebnisse:**

| Dienst | Status | Autostart |
|---|---|---|
| `ssh` | active (running) | disabled |
| `cron` | active (running) | enabled |
| `systemd-timesyncd` | active (running) | enabled |

**Erklärung der Statusfelder:**
- `Loaded` → Wurde die Unit-Datei korrekt geladen?
- `Active` → Aktueller Zustand: `active`, `inactive`, `failed`
- `Main PID` → Prozess-ID des Hauptprozesses
- `CGroup` → Zugehörige Control Group

**Beobachtung bei `cron`:** Die alle 10 Minuten erscheinenden Einträge in `auth.log` stammen von `debian-sa1` — einem Systemstatistik-Tool, das von cron regelmäßig ausgeführt wird.

---

### 2.3 Dienste starten, stoppen und neu starten

Verwendeter Dienst: `systemd-timesyncd` (nicht-kritisch, synchronisiert die Systemzeit)

```bash
sudo systemctl stop systemd-timesyncd
systemctl status systemd-timesyncd
```

**Output:**
```
Active: inactive (dead) since Wed 2026-03-11 15:00:36 CET
systemd[1]: Stopped systemd-timesyncd.service - Network Time Synchronization
```

```bash
sudo systemctl start systemd-timesyncd
systemctl status systemd-timesyncd
```

**Output:**
```
Active: active (running) since Wed 2026-03-11 15:01:24 CET
Main PID: 30015
systemd-timesyncd[30015]: Contacted time server [2620:2d:4000:1::40]:123 (ntp.ubuntu.com)
```

```bash
sudo systemctl restart systemd-timesyncd
systemctl status systemd-timesyncd
```

**Output:**
```
Active: active (running) since Wed 2026-03-11 15:02:27 CET
Main PID: 30064
```

**Unterschied `stop+start` vs `restart`:**
- `stop` + `start` → zwei separate Befehle, längere Ausfallzeit
- `restart` → atomare Operation, minimale Ausfallzeit — bevorzugt in der Produktion

**Beobachtung:** Bei jedem Start/Restart erhält der Dienst eine neue PID (`778` → `30015` → `30064`).

---

### 2.4 Autostart aktivieren und deaktivieren

```bash
systemctl is-enabled systemd-timesyncd
# → enabled
```

```bash
sudo systemctl disable systemd-timesyncd
```

**Output:**
```
Removed "/etc/systemd/system/dbus-org.freedesktop.timesync1.service"
Removed "/etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service"
```

```bash
systemctl is-enabled systemd-timesyncd
# → disabled
```

```bash
sudo systemctl enable systemd-timesyncd
```

**Output:**
```
Created symlink /etc/systemd/system/sysinit.target.wants/systemd-timesyncd.service → /usr/lib/systemd/system/systemd-timesyncd.service
```

```bash
systemctl is-enabled systemd-timesyncd
# → enabled
```

**Wie funktioniert enable/disable technisch?**  
`enable` erstellt Symlinks in `/etc/systemd/system/`, die systemd beim Boot folgt.  
`disable` entfernt diese Symlinks — der Dienst bleibt installiert, startet aber nicht mehr automatisch.

---

### Zusammenfassung: `systemctl`-Befehle

| Befehl | Wirkung | Persistent? |
|---|---|---|
| `systemctl start <dienst>` | Startet den Dienst jetzt | ❌ Nein |
| `systemctl stop <dienst>` | Stoppt den Dienst jetzt | ❌ Nein |
| `systemctl restart <dienst>` | Neustart jetzt | ❌ Nein |
| `systemctl enable <dienst>` | Autostart beim Boot aktivieren | ✅ Ja |
| `systemctl disable <dienst>` | Autostart beim Boot deaktivieren | ✅ Ja |
| `systemctl enable --now <dienst>` | Enable + sofort starten | ✅ Ja |
| `systemctl is-enabled <dienst>` | Autostart-Status prüfen | — |
| `systemctl status <dienst>` | Aktuellen Status anzeigen | — |

**Merksatz:** `start/stop` wirkt **jetzt**. `enable/disable` wirkt **beim nächsten Boot**.
