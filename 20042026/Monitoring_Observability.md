# Aufgabe: Monitoring und Observability an einem Cloud-Webdienst
**Datum:** 20.04.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Diese Aufgabe basiert auf praktischen Erfahrungen aus dem Caddy WAF + Grafana + Prometheus Setup (25.03.2026) sowie täglicher Arbeit mit Systemlogs und Docker-Containern.

---

## Aufgabe 1 — System und Beobachtungspunkte erfassen

### Gewählter Dienst: nginx (via Docker)

| Eigenschaft | Wert |
|---|---|
| Dienst | nginx Webserver |
| Port/URL | localhost:8090 (Docker) / localhost:8000 |
| Art | Webserver / Reverse Proxy |
| Log-Quelle | `docker compose logs web` / `/var/log/nginx/` |
| Metriken-Quelle | `docker stats`, `top`, `free`, `df` |

### Erreichbarkeit prüfen

```bash
# Normale Anfrage
curl -s -o /dev/null -w "%{http_code} %{time_total}s" http://localhost:8090/
# → 200 0.003s

# Nicht vorhandener Pfad
curl -s -o /dev/null -w "%{http_code} %{time_total}s" http://localhost:8090/nicht-vorhanden
# → 404 0.002s

# Mit Zeitmessung
time curl -s http://localhost:8090/ > /dev/null
# → real 0m0.004s
```

**Beobachtungstabelle:**

| Uhrzeit | Zielpfad | HTTP-Status | Antwortzeit |
|---|---|---|---|
| 16:05 | / | 200 | ~3ms |
| 16:05 | /nicht-vorhanden | 404 | ~2ms |
| 16:06 | / (mit time) | 200 | ~4ms |

---

## Aufgabe 2 — Baseline für Metriken erstellen

### Messung mit docker stats und free

```bash
docker stats --no-stream compose-web compose-redis
free -h
df -h
uptime
```

**Baseline-Tabelle (3 Messpunkte):**

| Metrik | Messung 1 | Messung 2 | Messung 3 |
|---|---|---|---|
| CPU nginx | 0.00% | 0.00% | 0.01% |
| RAM nginx | 10.14MB | 10.20MB | 10.18MB |
| CPU redis | 0.61% | 0.43% | 0.52% |
| RAM redis | 9.97MB | 9.98MB | 9.97MB |
| Load Average | 0.12 | 0.15 | 0.11 |
| Antwortzeit | ~3ms | ~3ms | ~4ms |

**Einschätzung:**
```
Stabile Werte    : RAM (kaum Schwankung), Antwortzeit
Schwankende Werte: CPU (abhängig von Requests), Load Average

Top 3 dauerhaft überwachen:
→ Antwortzeit (SLA-Indikator)
→ CPU-Auslastung (Überlastung erkennen)
→ RAM-Verbrauch (Memory Leak erkennen)
```

---

## Aufgabe 3 — Logs gezielt untersuchen

### Requests erzeugen

```bash
# 5 erfolgreiche Anfragen
for i in {1..5}; do curl -s http://localhost:8090/ > /dev/null; done

# 3 fehlerhafte Anfragen
curl http://localhost:8090/fehler-1
curl http://localhost:8090/fehler-2
curl http://localhost:8090/admin-nicht-vorhanden
```

### Logs analysieren

```bash
docker compose logs web
```

**5 aussagekräftige Log-Zeilen:**

```
# 1. Erfolgreiche Anfrage
172.19.0.1 - - [25/Apr/2026:16:05:37 +0000] "GET / HTTP/1.1" 200 236 "-" "curl/8.5.0"
→ Normalfall: 200, curl-Client, 236 Bytes

# 2. Nicht vorhandener Pfad
172.19.0.1 - - [25/Apr/2026:16:06:12 +0000] "GET /fehler-1 HTTP/1.1" 404 153 "-" "curl/8.5.0"
→ Fehlerfall: 404, Pfad nicht gefunden

# 3. Nginx Startup
[notice] nginx/1.29.8 nginx started
→ Dienst erfolgreich gestartet

# 4. Worker-Prozesse
[notice] start worker process 30
→ nginx nutzt alle CPU-Kerne (12 Worker)

# 5. IPv6 Konfiguration
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6
→ automatische Konfiguration beim Start
```

**Unterschied Normalfall vs. Fehlerfall klar erkennbar:**
```
Erfolg → HTTP 200 → Bytes übertragen
Fehler → HTTP 404 → kleinere Byte-Anzahl (Fehlerseite)
```

---

## Aufgabe 4 — Leistung unter kleiner Last beobachten

### Last erzeugen

```bash
# 100 Requests in einer Schleife
for i in {1..100}; do curl -s http://localhost:8090/ > /dev/null; done
```

### Vorher-Nachher Vergleich

| Metrik | Vor Last | Während Last | Nach Last |
|---|---|---|---|
| CPU nginx | 0.00% | 2-5% | 0.00% |
| RAM nginx | 10.14MB | 10.30MB | 10.14MB |
| Antwortzeit | ~3ms | ~5ms | ~3ms |
| Verbindungen | 1 | mehrere | 1 |

**Beobachtungen:**
```
→ CPU steigt kurz bei Last → kehrt sofort zurück
→ RAM kaum beeinflusst → nginx ist sehr effizient
→ Antwortzeit leicht erhöht → aber < 10ms → akzeptabel
→ Last auch in Logs sichtbar → viele GET / 200 Einträge
```

---

## Aufgabe 5 — Monitoring vs. Observability

### Monitoring — Was regelmäßig überwacht wird

```
1. HTTP-Antwortzeit
   Signal  : curl -w "%{time_total}" http://localhost/
   Auffällig: > 500ms = Problem
   Warum   : direkte Nutzererfahrung

2. HTTP-Fehlerrate (4xx/5xx)
   Signal  : Anteil der Fehler-Statuscodes in den Logs
   Auffällig: > 5% Fehler = Problem
   Warum   : zeigt ob Dienst korrekt antwortet

3. CPU-Auslastung
   Signal  : docker stats / top
   Auffällig: dauerhaft > 80% = Problem
   Warum   : Überlastung führt zu Verlangsamung
```

### Observability — Fehleranalyse in 4 Schritten

**Fehlerfall: 404 auf /admin-nicht-vorhanden**

```
Schritt 1 — Erstes sichtbares Signal:
   HTTP 404 in der Antwort beim curl-Test

Schritt 2 — Metrik die aufmerksam macht:
   Erhöhte Fehlerrate (4xx) im Monitoring-Dashboard
   → Grafana Alert "Fehlerrate > 5%"

Schritt 3 — Logs helfen bei Einordnung:
   172.19.0.1 "GET /admin-nicht-vorhanden" 404
   → Pfad existiert nicht, kein Server-Fehler
   → kein 500 = Server läuft korrekt

Schritt 4 — Fehlende Information:
   → Wer hat die Anfrage gemacht? (nur IP sichtbar)
   → Warum wurde /admin aufgerufen? (kein Kontext)
   → Distributed Tracing würde helfen (z.B. Jaeger)
```

### Mini-Timeline einer Anfrage

```
16:05:37.000 → Client sendet GET / HTTP/1.1
16:05:37.001 → nginx empfängt Anfrage
16:05:37.002 → nginx liest index.html
16:05:37.003 → nginx sendet 200 + 236 Bytes
16:05:37.003 → Log-Eintrag geschrieben
```

---

## Erweiterungsaufgabe 1 — Mini Monitoring-Set

| # | Was überwacht wird | Warum | Datenquelle | Auffällig wenn |
|---|---|---|---|---|
| 1 | HTTP Antwortzeit | SLA-Indikator | curl -w time_total | > 500ms |
| 2 | HTTP Fehlerrate | Service-Gesundheit | nginx access.log | > 5% 4xx/5xx |
| 3 | CPU-Auslastung | Überlastung | docker stats / Prometheus | > 80% dauerhaft |
| 4 | RAM-Verbrauch | Memory Leak | docker stats / free | kontinuierlich steigend |
| 5 | Disk-Auslastung | Log-Rotation | df -h | > 85% |

---

## Monitoring vs. Observability — Zusammenfassung

```
MONITORING = Was ist der aktuelle Zustand?
→ Metriken, Schwellenwerte, Alerts
→ "CPU ist bei 90%" → Alert!
→ Beantwortet: IST etwas falsch?

OBSERVABILITY = Warum ist der Zustand so?
→ Metriken + Logs + Traces korreliert
→ "CPU 90% wegen Request-Spike auf /api/upload"
→ Beantwortet: WARUM ist etwas falsch?

Die drei Säulen der Observability:
→ Metrics (Prometheus, CloudWatch)
→ Logs    (Loki, CloudWatch Logs)
→ Traces  (Jaeger, AWS X-Ray)
```

**Verbindung zu AWS:**
```
Monitoring   → CloudWatch Metrics + Alarms
Logs         → CloudWatch Logs + Log Insights
Traces       → AWS X-Ray (Distributed Tracing)
Dashboard    → CloudWatch Dashboard / Grafana
Alert        → SNS → E-Mail / Slack / PagerDuty
```
