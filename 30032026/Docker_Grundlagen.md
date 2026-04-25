# Aufgabe: Docker-Grundlagen praktisch anwenden
**Datum:** 30.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Umgebung

```
Docker Version : 29.3.1
Context        : desktop-linux
Storage Driver : overlay2
CPUs           : 12
RAM            : 5.569 GiB
```

---

## Aufgabe 1 — Docker prüfen und ersten Container starten

### Docker-Version und System-Info prüfen

```bash
docker --version
# Docker version 29.3.1, build c2be9cc

docker info
# Containers: 6 (1 running, 5 stopped)
# Images: 5
```

### Vorhandene Images und Container anzeigen

```bash
docker images
```

**Vorhandene Images vor dem Start:**
```
curl-test:latest            13.9MB
grafana/grafana:latest      761MB
hello-docker:latest         161MB
prom/node-exporter:latest   25.7MB
prom/prometheus:latest      390MB
```

```bash
docker ps -a
```

**Vorhandene Container:**
```
node-exporter     → Up (running)
grafana-container → Exited (255)
prometheus        → Exited (255)
serene_germain    → Exited (0) — hello-docker
great_herschel    → Exited (0) — hello-docker
tender_noyce      → Exited (0) — curl-test
```

### Wichtige Erkenntnisse

```
docker ps    → zeigt nur LAUFENDE Container
docker ps -a → zeigt ALLE Container (running + stopped)

Exit Code 0   → Container normal beendet (kein Fehler)
Exit Code 255 → Container gestoppt oder abgestürzt
```

---

## Aufgabe 2 — Web-Container starten und sichtbar machen

### nginx Container starten

```bash
docker run -d --name mein-webserver -p 8000:80 nginx
```

**Parameter erklärt:**
```
-d           → detached (läuft im Hintergrund)
--name       → eindeutiger Name für den Container
-p 8000:80   → Port-Mapping: localhost:8000 → Container:80
nginx        → Image-Name (wird von Docker Hub geladen)
```

**Output beim ersten Start:**
```
Unable to find image 'nginx:latest' locally
→ Image nicht lokal vorhanden → automatischer Download

Pulling from library/nginx:
3531af2bc2a9: Pull complete  ← Layer 1
ce776bbcda0d: Pull complete  ← Layer 2
...
→ 7 Layers heruntergeladen (jede Schicht separat)
```

### Container prüfen

```bash
docker ps
```

```
CONTAINER ID   IMAGE   PORTS                    NAMES
9f4d86a8078d   nginx   0.0.0.0:8000->80/tcp     mein-webserver
```

```
0.0.0.0:8000->80/tcp bedeutet:
→ 0.0.0.0   = hört auf allen Netzwerk-Interfaces
→ 8000       = Port auf dem Host (deine Maschine)
→ 80         = Port im Container
```

### Webserver testen

```bash
curl http://localhost:8000
# → "Welcome to nginx!" Seite erfolgreich angezeigt
```

---

## Aufgabe 3 — Container verwalten: Lifecycle

### Container stoppen

```bash
docker stop mein-webserver
docker ps -a
# mein-webserver → Exited (0) 21 seconds ago
```

### Container neu starten

```bash
docker start mein-webserver
docker ps
# mein-webserver → Up 37 seconds
```

### Zweiten Container aus derselben Image starten

```bash
docker run -d --name zweiter-webserver -p 8001:80 nginx
docker ps
```

```
fc7b7d1b35da   nginx   0.0.0.0:8001->80/tcp   zweiter-webserver
9f4d86a8078d   nginx   0.0.0.0:8000->80/tcp   mein-webserver
```

**Wichtige Erkenntnis:**
```
Eine Image → beliebig viele Container !
Wie eine Vorlage die man mehrfach verwenden kann.
Jeder Container ist vollständig isoliert.
```

### Container entfernen

```bash
docker stop zweiter-webserver
docker rm zweiter-webserver
docker ps -a
# zweiter-webserver ist vollständig verschwunden
```

**Container Lifecycle:**
```
docker run   → Container erstellen und starten
docker stop  → Container stoppen (bleibt erhalten)
docker start → gestoppten Container wieder starten
docker rm    → Container dauerhaft löschen
               (nur möglich wenn gestoppt)
```

---

## Aufgabe 4 — Eigenes Docker-Image bauen

### Projektstruktur

```bash
mkdir ~/cloud/linux/30032026/docker-web
cd ~/cloud/linux/30032026/docker-web
```

### index.html erstellen

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mein erstes Docker Image</title>
</head>
<body>
    <h1>Mein erstes Docker Image</h1>
    <p>Name: Gilles</p>
    <p>Datum: 30.03.2026</p>
    <p>Hinweis: Mein erstes selbst gebautes Docker-Image!</p>
</body>
</html>
```

### Dockerfile erstellen

```dockerfile
FROM nginx:latest
COPY index.html /usr/share/nginx/html/index.html
```

**Dockerfile erklärt:**
```
FROM nginx:latest
→ Basis-Image: nginx (bereits bewährter Webserver)
→ Wir bauen DARAUF auf — kein Rad neu erfinden

COPY index.html /usr/share/nginx/html/index.html
→ Unsere HTML-Datei ins Image kopieren
→ Überschreibt die Standard-nginx-Seite
→ /usr/share/nginx/html/ = nginx Web-Root-Verzeichnis
```

### Image bauen

```bash
docker build -t mein-webimage:v1 .
```

**Build-Output:**
```
[+] Building 0.2s (7/7) FINISHED

Step 1/2 → FROM nginx:latest         (0.1s — lokal vorhanden)
Step 2/2 → COPY index.html ...       (0.0s)
→ exporting layers                   (0.0s)
→ naming to docker.io/library/mein-webimage:v1
```

### Image prüfen und Container starten

```bash
docker images | grep mein-webimage
# mein-webimage:v1   20d39618d1b8   161MB

docker run -d --name mein-web-container -p 8080:80 mein-webimage:v1
curl http://localhost:8080
# → Eigene HTML-Seite wird angezeigt ✅
```

---

## Erweiterungsaufgabe 1 — Image versionieren

### index.html für v2 aktualisieren

```html
<p>Version: v2 - Aktualisierte Version!</p>
```

### v2 bauen

```bash
docker build -t mein-webimage:v2 .
```

**Wichtige Beobachtung — Layer Caching:**
```
CACHED [1/2] FROM docker.io/library/nginx:latest  ← aus Cache!
[2/2] COPY index.html ...                          ← neu gebaut

→ Docker erkennt: Layer 1 (FROM nginx) hat sich nicht geändert
→ Layer 1 wird aus Cache geladen → viel schneller!
→ Nur geänderte Layers werden neu gebaut
→ Build in 0.1s statt erneut herunterladen
```

### Beide Versionen gleichzeitig laufen lassen

```bash
docker run -d --name mein-web-v2 -p 8090:80 mein-webimage:v2

# v1 auf Port 8080 → alte Version
# v2 auf Port 8090 → neue Version
```

```bash
curl http://localhost:8080  # → v1 ohne "Aktualisierte Version"
curl http://localhost:8090  # → v2 mit "Aktualisierte Version" ✅
```

**Images Übersicht:**
```
mein-webimage:v1   20d39618d1b8   161MB
mein-webimage:v2   ce2cf66b3757   161MB
```

---

## Erweiterungsaufgabe 2 — Docker-Umgebung aufräumen

### Nicht mehr benötigte Container entfernen

```bash
docker rm serene_germain great_herschel tender_noyce
```

### Finaler Zustand

```bash
docker ps -a
```

```
mein-web-v2        Up   → Port 8090 (mein-webimage:v2)
mein-web-container Up   → Port 8080 (mein-webimage:v1)
mein-webserver     Up   → Port 8000 (nginx)
node-exporter      Up   → Port 9100 (Monitoring)
grafana-container  Exit → Port 3000 (Monitoring)
prometheus         Exit → Port 9090 (Monitoring)
```

---

## Aufgabe 5 — VM vs Container Vergleich

| Vergleichspunkt | Virtuelle Maschine (VM) | Container |
|---|---|---|
| **Startzeit** | 1-5 Minuten | Sekunden (< 1s) |
| **Image-Größe** | Gigabytes (GB) | Megabytes (MB) |
| **OS** | Eigenes vollständiges OS | Teilt Host-OS Kernel |
| **Isolation** | Vollständig (Hardware-Ebene) | Prozess-Ebene |
| **Ressourcen** | Fest zugewiesen | Dynamisch geteilt |
| **Portabilität** | Eingeschränkt | Sehr hoch (läuft überall) |
| **Verwaltung** | Hypervisor (KVM, VMware) | Container Runtime (Docker) |
| **Skalierung** | Langsamer (Minuten) | Sehr schnell (Sekunden) |
| **Typischer Einsatz** | Legacy-Apps, volle OS-Kontrolle | Microservices, CI/CD |

### Praxisentscheidungen

**Situation 1: Webanwendung schnell testen**
```
→ Container (Docker)
Warum: In Sekunden gestartet, einfaches Stoppen/Löschen,
       "works on my machine" Problem gelöst, pay-per-use in Cloud
```

**Situation 2: Vollständig getrenntes System mit eigenem OS**
```
→ Virtuelle Maschine (EC2, Azure VM)
Warum: Eigenes OS nötig (z.B. Windows auf Linux-Host),
       vollständige Isolation, Legacy-Anwendungen die spezifisches OS brauchen
```

---

## Wichtige Docker-Befehle Zusammenfassung

```bash
# Images
docker images              # alle Images anzeigen
docker pull nginx          # Image herunterladen
docker build -t name:tag . # eigenes Image bauen
docker rmi image-name      # Image löschen

# Container
docker run -d --name NAME -p HOST:CONTAINER IMAGE  # Container starten
docker ps                  # laufende Container
docker ps -a               # alle Container
docker stop NAME           # Container stoppen
docker start NAME          # Container starten
docker rm NAME             # Container löschen
docker logs NAME           # Container-Logs anzeigen

# Informationen
docker info                # System-Informationen
docker inspect NAME        # Details zu Container/Image
```

---

## Reflexion

**Was ich direkt beobachten konnte:**
```
→ Container starten in Sekunden (nginx: < 1s)
→ Layer Caching: v2 Build in 0.1s (Layer 1 aus Cache)
→ Eine Image → mehrere Container gleichzeitig (v1 + v2 + mein-webserver)
→ Container verschwinden vollständig nach docker rm
→ Images bleiben auch nach Container-Löschung erhalten
```

**Verbindung zu Cloud-Konzepten:**
```
→ AWS ECS  → deployt Docker-Container auf verwalteter Infrastruktur
→ AWS EKS  → Kubernetes orchestriert Docker-Container
→ CI/CD    → docker build → docker push → automatisches Deployment
→ Microservices → jeder Service = eigener Container
```
