# Aufgabe: Logs, Monitoring und einfache Alerts im Cloud-Alltag
**Datum:** 21.04.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Basiert auf praktischen Erfahrungen mit Systemlogs, Docker-Monitoring und dem Caddy WAF + Grafana + Prometheus Setup.

---

## Aufgabe 1 — Logquellen auf dem System finden

### System-Logs

| Datei/Befehl | Zweck | Erwartete Ereignisse |
|---|---|---|
| `/var/log/syslog` | Allgemeine Systemmeldungen | Kernel, Dienste, Hardware |
| `journalctl -u ssh` | SSH-Dienst Logs | Verbindungen, Fehler, Start/Stop |

### Application-Log

| Datei/Befehl | Zweck | Erwartete Ereignisse |
|---|---|---|
| `docker compose logs web` | nginx Container Logs | HTTP-Requests, Fehler, Start |

### Security-Log

| Datei/Befehl | Zweck | Erwartete Ereignisse |
|---|---|---|
| `/var/log/auth.log` | Authentifizierungsereignisse | SSH-Login, sudo, fehlgeschlagene Logins |

### Übersicht `/var/log/`

```bash
ls /var/log/
```

```
auth.log        → Authentifizierung (SSH, sudo, PAM)
syslog          → Allgemeine Systemmeldungen
kern.log        → Kernel-Meldungen
dpkg.log        → Paketinstallationen
fail2ban.log    → Automatisch gesperrte IPs
nginx/          → nginx Access und Error Logs
journal/        → systemd Journal (journalctl)
```

---

## Aufgabe 2 — System- und Sicherheitsereignisse erkennen

### Logeinträge analysieren

```bash
sudo tail -f /var/log/auth.log
journalctl -u ssh --since "1 hour ago"
```

**6 aussagekräftige Log-Einträge:**

| # | Zeitpunkt | Dienst | Ereignis | Einordnung |
|---|---|---|---|---|
| 1 | 14:26:25 | sshd | `Accepted password for dci-student from 192.168.178.133` | Normal — SSH-Login von bekannter IP |
| 2 | 14:08:01 | sudo | `dci-student: COMMAND=/usr/bin/tail -f /var/log/auth.log` | Normal — sudo-Befehl protokolliert |
| 3 | 13:35:01 | CRON | `session opened for user root` | Normal — geplante Aufgabe |
| 4 | 13:35:01 | CRON | `session closed for user root` | Normal — Aufgabe abgeschlossen |
| 5 | 14:20:12 | sshd | `Server listening on 0.0.0.0 port 22` | Normal — SSH-Dienst gestartet |
| 6 | 14:26:25 | systemd-logind | `New session 75 of user dci-student` | Normal — neue Benutzersitzung |

**Wichtige Erkenntnis:**
```
→ Jede sudo-Nutzung wird mit User, Pfad und Befehl geloggt
→ SSH-Verbindungen zeigen IP-Adresse des Clients
→ CRON-Jobs alle 10 Minuten → erkennbar in auth.log
→ fail2ban blockiert IPs nach zu vielen Fehlversuchen automatisch
```

---

## Aufgabe 3 — Wichtige Systemmetriken erfassen

### CPU

```bash
uptime
top -bn1 | head -5
```

```
Load Average: 0.12, 0.15, 0.11
→ Gut: unter Anzahl der CPU-Kerne (12)
→ Kritisch: dauerhaft > 12 (= alle Kerne ausgelastet)
→ Warum überwachen: CPU-Spitzen zeigen Überlastung oder Angriffe
```

### RAM

```bash
free -h
```

```
              total    used    free    available
Mem:          31Gi     8.2Gi   18Gi    22Gi
Swap:         2.0Gi    0B      2.0Gi

→ Gut: available > 20% des totals
→ Kritisch: Swap-Nutzung steigt → RAM erschöpft
→ Warum überwachen: Memory Leaks frühzeitig erkennen
```

### Festplatten

```bash
df -h
```

```
Filesystem      Size    Used    Avail   Use%
/dev/sda1       100G    45G     55G     45%

→ Gut: < 80% Nutzung
→ Kritisch: > 85% → Logs können nicht mehr geschrieben werden
→ Warum überwachen: volle Disk → Dienst-Absturz
```

### Netzwerk

```bash
ss -tulnp
ip a
```

```
Port 22   → SSH (listening)
Port 80   → HTTP nginx
Port 443  → HTTPS nginx
Port 9100 → node-exporter (Prometheus)

→ Gut: nur erwartete Ports offen
→ Kritisch: unbekannte Ports offen → Sicherheitsrisiko
→ Warum überwachen: offene Ports = potenzielle Angriffsfläche
```

---

## Aufgabe 4 — Monitoring-Checkblatt

| # | Was wird geprüft | Wie | Unauffällig | Kritisch |
|---|---|---|---|---|
| 1 | CPU-Auslastung | `uptime` / Load Average | Load < CPU-Kerne | Load > CPU-Kerne dauerhaft |
| 2 | RAM-Auslastung | `free -h` | Available > 20% | Swap aktiv + RAM < 10% frei |
| 3 | Disk-Kapazität | `df -h` | < 80% belegt | > 85% belegt |
| 4 | Netzwerk/Ports | `ss -tulnp` | Nur bekannte Ports | Unbekannte Ports offen |
| 5 | SSH-Dienst Status | `systemctl status ssh` | active (running) | inactive / failed |
| 6 | nginx-Dienst | `docker compose ps` | Up | Exited / Restarting |
| 7 | Fehlgeschlagene Logins | `grep "Failed" /var/log/auth.log` | < 5 pro Stunde | > 20 pro Stunde → Brute Force |

```bash
# Schnell-Check Skript
echo "=== CPU ===" && uptime
echo "=== RAM ===" && free -h
echo "=== DISK ===" && df -h /
echo "=== PORTS ===" && ss -tulnp
echo "=== DIENSTE ===" && systemctl status ssh --no-pager -l
echo "=== FAILED LOGINS ===" && grep "Failed password" /var/log/auth.log | tail -5
```

---

## Aufgabe 5 — Warnschwellen und Alerts planen

| Alert | Auslöser | Schweregrad | Benachrichtigung | Warum wichtig |
|---|---|---|---|---|
| CPU-Überlastung | Load Average > CPU-Kerne für > 5min | ⚠️ Warning | Slack/E-Mail | Dienst wird langsam, Nutzer betroffen |
| RAM-Erschöpfung | Available RAM < 10% | 🔴 Critical | Sofort: PagerDuty | OOM-Killer beendet Prozesse |
| Disk voll | Disk > 85% belegt | ⚠️ Warning | E-Mail | Logs können nicht geschrieben werden |
| Dienst down | nginx/SSH nicht erreichbar | 🔴 Critical | Sofort: PagerDuty | Service-Ausfall für Nutzer |
| Brute Force | > 20 Failed Logins/Stunde | ⚠️ Warning | Slack | Angriff auf SSH erkennbar |

**Alert-Philosophie:**
```
→ Nicht zu empfindlich → zu viele Fehlalarme = Alarm-Fatigue
→ Nicht zu grob → echte Probleme werden übersehen
→ Jeder Alert muss handlungsrelevant sein
→ "Wenn dieser Alert auslöst, muss jemand etwas tun"
```

---

## Erweiterungsaufgabe 1 — Loganalyse nginx

```bash
docker compose logs web | grep -E "404|500|error"
```

**Beobachtungen:**
```
→ 404 bei unbekannten Pfaden → normal (Scanner, Tippfehler)
→ Viele 404 auf /admin, /wp-login.php → automatisierte Angriffe
→ 200 auf / → normale Zugriffe
→ Worker-Prozesse (12) → entspricht CPU-Kernen
→ Alert empfehlung: > 100 x 404/Stunde → suspicious traffic Alert
```

---

## Erweiterungsaufgabe 2 — Mini-Dashboard Entwurf

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVER DASHBOARD                          │
├──────────────┬──────────────┬──────────────┬────────────────┤
│     CPU      │     RAM      │     DISK     │   NETZWERK     │
│  🟢 12%     │  🟢 26%     │  🟡 45%     │  🟢 OK        │
│  Load: 0.12  │  22GB frei   │  55GB frei   │  Port 22,80✅  │
├──────────────┴──────────────┴──────────────┴────────────────┤
│ DIENSTE                                                      │
│  🟢 SSH     🟢 nginx     🟢 node-exporter     🔴 grafana   │
├─────────────────────────────────────────────────────────────┤
│ LETZTE FEHLER (auth.log)                                     │
│  keine fehlgeschlagenen Logins in der letzten Stunde ✅     │
└─────────────────────────────────────────────────────────────┘
```

**Ampel-Logik:**
```
🟢 Grün   → alles normal
🟡 Gelb   → Warnschwelle erreicht → beobachten
🔴 Rot    → kritisch → sofort handeln
```

---

## Reflexion

**Wichtigste Erkenntnisse:**

```
1. Logs = Vergangenheit, Metriken = Gegenwart
   → Logs erklären WARUM etwas passiert ist
   → Metriken zeigen WAS gerade passiert

2. auth.log ist Gold für Security
   → Jeder SSH-Login, sudo-Befehl, fehlgeschlagener Login
   → fail2ban liest auth.log und sperrt automatisch

3. Alert-Fatigue ist real
   → Zu viele Alerts → werden ignoriert
   → Nur Alerts die Handlung erfordern

4. Disk ist oft unterschätzt
   → Volle Disk → keine Logs → Dienst stürzt ab
   → Immer als erstes prüfen bei unerklärlichen Fehlern
```

**Verbindung zu AWS:**
```
Logs      → CloudWatch Logs / Loki
Metriken  → CloudWatch Metrics / Prometheus
Alerts    → CloudWatch Alarms → SNS → E-Mail/Slack/PagerDuty
Dashboard → CloudWatch Dashboard / Grafana
Security  → AWS GuardDuty (wie fail2ban aber für die Cloud)
```
