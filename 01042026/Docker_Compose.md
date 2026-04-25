# Aufgabe: Docker Compose, Docker Hub und Container-Monitoring
**Datum:** 01.04.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Projektstruktur

```
01042026/
├── cloud-basics-compose/
│   ├── docker-compose.yml
│   └── webapp/
│       ├── Dockerfile
│       └── index.html
```

---

## Aufgabe 1 — Images aus Docker Hub abrufen

### Images herunterladen

```bash
docker pull nginx:alpine
docker pull redis:alpine
```

**Wichtige Beobachtung — Shared Layers:**
```
nginx:alpine Pull:
6a0ac1617861: Already exists  ← Alpine Base-Layer bereits vorhanden!
82736a35d0e7: Pull complete
...7 Layers total

redis:alpine Pull:
6a0ac1617861: Already exists  ← DERSELBE Alpine Base-Layer!
15c77f17eed6: Pull complete
...7 Layers total

→ Alpine Base-Layer wird von BEIDEN Images geteilt
→ Nur einmal auf Disk gespeichert → spart Speicherplatz
```

### Images vergleichen

```bash
docker image ls | grep -E "nginx|redis"
```

```
nginx:alpine   62.2MB  ← Alpine-Variante: kompakt
nginx:latest   161MB   ← Standard: 2.6x größer!
redis:alpine   97.3MB
```

### Nginx testen und aufräumen

```bash
docker run -d --name test-nginx -p 8888:80 nginx:alpine
curl http://localhost:8888  # → "Welcome to nginx!" ✅
docker stop test-nginx && docker rm test-nginx
```

---

## Aufgabe 2 — Eigenes Web-Image bauen

### Projektstruktur anlegen

```bash
mkdir webapp && cd webapp
```

### index.html

```html
<!DOCTYPE html>
<html>
<head><title>DCI Cloud Projekt</title></head>
<body>
    <h1>DCI Cloud Projekt</h1>
    <p>Name: Gilles</p>
    <p>Datum: 01.04.2026</p>
    <p>Bereitgestellt mit Docker</p>
    <p>Version: v1</p>
</body>
</html>
```

### Dockerfile

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

### Image bauen und testen

```bash
docker build -t dci-webapp:v1 .
docker run -d --name dci-webapp_v1 -p 8080:80 dci-webapp:v1
curl http://localhost:8080  # → eigene HTML-Seite ✅
```

```
dci-webapp:v1 → 62.2MB
→ gleich groß wie nginx:alpine!
→ unsere index.html hat kaum Overhead hinzugefügt
```

---

## Aufgabe 4 — Multi-Service-Setup mit Docker Compose

### Was ist Docker Compose?

```
docker-compose.yml → definiert QUOI lancer (Images, Ports, Namen...)
docker compose up  → startet ALLES was im yml definiert ist
docker compose down → stoppt und löscht ALLES

→ Infrastructure as Code in miniature
→ Das yml-File IST die Architektur
```

### docker-compose.yml

```yaml
services:
  web:
    image: dci-webapp:v1
    container_name: compose-web
    ports:
      - "8090:80"
    restart: always

  cache:
    image: redis:alpine
    container_name: compose-redis
    restart: always
```

**Felder erklärt:**

| Feld | Bedeutung |
|---|---|
| `services` | Liste aller Services/Container |
| `image` | Welches Docker Image verwenden |
| `container_name` | Eindeutiger Name des Containers |
| `ports` | Port-Mapping: Host:Container |
| `restart: always` | Container neustart bei Absturz automatisch |

### Setup starten

```bash
docker compose up -d
```

```
✔ Network cloud-basics-compose_default  Created  ← automatisches Netzwerk!
✔ Container compose-web                 Started
✔ Container compose-redis               Started
```

**Wichtig:** Docker Compose erstellt automatisch ein **gemeinsames Netzwerk** für alle Services — sie können sich gegenseitig über ihren Service-Namen erreichen (z.B. `cache:6379`).

### Setup prüfen

```bash
docker compose ps
```

```
NAME            IMAGE           PORTS                    STATUS
compose-redis   redis:alpine    6379/tcp                 Up
compose-web     dci-webapp:v1   0.0.0.0:8090->80/tcp    Up
```

```bash
curl http://localhost:8090
# → DCI Cloud Projekt Seite ✅
```

### Fehler und Lösung: Port bereits belegt

```
Error: Bind for 0.0.0.0:8080 failed: port is already allocated
→ dci-webapp_v1 nutzte Port 8080
→ Lösung: dci-webapp_v1 stoppen → docker compose up -d → Erfolg
→ Port in docker-compose.yml auf 8090 geändert
```

### Vorteile von Docker Compose

```
1. Ein Befehl für alles
   → docker compose up -d → alle Services starten
   → docker compose down  → alle Services stoppen

2. Reproduzierbar
   → yml-Datei auf anderem Server → identisches Setup
   → "works on my machine" Problem gelöst

3. Automatisches Netzwerk
   → Services sehen sich gegenseitig per Name
   → web kann redis über "cache:6379" erreichen

4. Übersichtlichkeit
   → gesamte Architektur in einer Datei
   → einfach zu versionieren (Git)
```

---

## Aufgabe 5 — Logs und Ressourcennutzung überwachen

### Web-Service Logs

```bash
docker compose logs web
```

**Wichtige Log-Einträge:**
```
nginx/1.29.8 → nginx Version
OS: Linux 6.12.76-linuxkit → Container OS (linuxkit = Docker Desktop)
start worker process 30-41 → 12 Worker-Prozesse (= Anzahl CPUs)

172.19.0.1 - "GET / HTTP/1.1" 200 236 "curl/8.5.0"
→ unser curl-Test wurde geloggt!
→ Format: IP - Methode URL HTTP-Version Status Bytes UserAgent
```

### Ressourcennutzung messen

```bash
docker stats --no-stream compose-web compose-redis
```

```
CONTAINER     CPU %   MEM USAGE / LIMIT      MEM %   NET I/O
compose-web   0.00%   10.14MiB / 5.569GiB   0.18%   2.51kB / 1.02kB
compose-redis 0.61%   9.965MiB / 5.569GiB   0.17%   1.75kB / 126B
```

**Analyse:**

| Container | CPU | RAM | Bedeutung |
|---|---|---|---|
| compose-web | 0.00% | 10.14MB | Nginx im Ruhezustand → sehr effizient |
| compose-redis | 0.61% | 9.97MB | Redis leicht aktiv (Heartbeat/Housekeeping) |

**Was diese Werte zeigen:**
```
→ Beide Container zusammen: ~20MB RAM → extrem leichtgewichtig!
→ Zum Vergleich: eine VM mit Ubuntu braucht mind. 512MB RAM
→ Container sind 25x effizienter als VMs im Ruhezustand
→ Redis zeigt mehr CPU als nginx → Redis verwaltet intern Datenstrukturen
```

### Setup sauber stoppen

```bash
docker compose down
```

```
✔ Container compose-redis  Removed
✔ Container compose-web    Removed
✔ Network cloud-basics-compose_default  Removed
→ Alles sauber aufgeräumt in einem Befehl ✅
```

---

## Zusammenfassung: Wichtige Befehle

```bash
# Images
docker pull nginx:alpine          # Image herunterladen
docker image ls                   # alle Images anzeigen

# Docker Compose
docker compose up -d              # alle Services starten (detached)
docker compose down               # alle Services stoppen und löschen
docker compose ps                 # laufende Services anzeigen
docker compose logs web           # Logs eines Services anzeigen
docker compose logs -f web        # Logs live verfolgen (follow)

# Monitoring
docker stats --no-stream          # einmalige Ressourcen-Messung
docker stats                      # Live-Ressourcen-Monitoring
```

---

## Reflexion

**Größte Erkenntnisse:**

```
1. Docker Compose = Infrastructure as Code
   → Eine YAML-Datei beschreibt die gesamte Architektur
   → Reproduzierbar auf jedem System mit Docker

2. Automatisches Netzwerk
   → Compose erstellt ein internes Netzwerk
   → Services kommunizieren über Service-Namen (nicht IPs)
   → Basis für Microservices-Architektur

3. Effizienz
   → 2 Services = ~20MB RAM
   → nginx + redis starten in < 1 Sekunde
   → Gleiche Aufgabe mit VMs: > 1GB RAM, Minuten zum Starten
```

**Verbindung zu Cloud-Konzepten:**
```
docker-compose.yml  ≈  AWS CloudFormation Template
                    ≈  Terraform Konfiguration
                    ≈  Kubernetes YAML Manifest

docker compose up   ≈  terraform apply
docker compose down ≈  terraform destroy

→ Das Konzept "Infrastructure as Code" zieht sich durch alle Cloud-Tools!
→ Kubernetes ist im Grunde Docker Compose auf Enterprise-Level
```
