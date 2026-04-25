# Aufgabe: Docker Images verstehen und eigenes Admin-Tool-Image bauen
**Datum:** 31.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — Bestehende Docker Images erkunden

### Zwei Basis-Images herunterladen

```bash
docker pull alpine
docker pull ubuntu
```

**Alpine Download:**
```
6a0ac1617861: Pull complete
→ Nur 1 Layer heruntergeladen → sehr kompaktes Image
```

**Ubuntu Download:**
```
b40150c1c271: Pull complete
→ 1 Layer (aber mehr Metadaten intern)
```

### Images vergleichen

```bash
docker image ls
```

```
alpine:latest    →   8.45MB  ← extrem leichtgewichtig!
ubuntu:latest    →  78.1MB   ← 9x größer als Alpine
nginx:latest     → 161MB
grafana          → 761MB
```

**Warum ist Alpine so klein?**
```
→ Verwendet musl libc statt glibc (wie Ubuntu)
→ Verwendet busybox (minimale Unix-Werkzeuge in einer Datei)
→ Kein unnötige Software vorinstalliert
→ Ideal für Production-Container: weniger Angriffsfläche, schnellere Downloads
```

---

## Aufgabe 2 — Layer sichtbar machen

### History beider Images

```bash
docker history alpine
```

```
IMAGE          CREATED      CREATED BY                              SIZE
3cb067eab609   9 days ago   CMD ["/bin/sh"]                         0B
<missing>      9 days ago   ADD alpine-minirootfs-3.23.4-x86_64…   8.45MB
```

```bash
docker history ubuntu
```

```
IMAGE          CREATED       CREATED BY                              SIZE
0b1ebe5dd426   2 weeks ago   CMD ["/bin/bash"]                       0B
<missing>      2 weeks ago   ADD file:8ce1caf246e7c778b…             78.1MB
<missing>      2 weeks ago   LABEL org.opencontainers…               0B
<missing>      2 weeks ago   ARG LAUNCHPAD_BUILD_ARCH                0B
<missing>      2 weeks ago   ARG RELEASE                             0B
```

### Layer-Analyse

| Aspekt | Alpine | Ubuntu |
|---|---|---|
| Anzahl Layer | 2 | 5 |
| Größter Layer | 8.45MB | 78.1MB |
| Layers mit 0B | 1 | 4 |
| Komplexität | Sehr einfach | Mehr Metadaten |

**Wichtige Erkenntnisse:**
```
→ Layers mit 0B = nur Metadaten/Konfiguration (kein Disk-Verbrauch)
→ Layers mit MB = echte Dateien (nehmen tatsächlich Platz ein)
→ Layers werden zwischen Images GETEILT:
   nginx und mein-webimage basieren beide auf nginx
   → die nginx-Layers werden nur EINMAL auf Disk gespeichert!
→ Je weniger Layers → einfacher zu verstehen und zu debuggen
```

**Was ist ein Docker Image? (praktische Beobachtung)**
```
→ Eine geordnete Sammlung von schreibgeschützten Layers
→ Jede Dockerfile-Anweisung erstellt einen neuen Layer
→ Layers sind unveränderlich (immutable)
→ Layers können zwischen Images wiederverwendet werden
→ Ein Container = Image-Layers + ein beschreibbarer Layer oben drauf
```

---

## Aufgabe 3 — Projektordner vorbereiten

### Struktur anlegen

```bash
mkdir ~/cloud/linux/31032026/admin-toolbox
cd ~/cloud/linux/31032026/admin-toolbox
```

### check.sh

```bash
#!/bin/sh
echo "================================"
echo "  Admin Toolbox - System Check  "
echo "================================"
echo "Hostname    : $(hostname)"
echo "Datum       : $(date)"
echo "OS Info     : $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "--------------------------------"
cat /etc/motd.txt 2>/dev/null || echo "Kein MOTD gefunden"
echo "================================"
```

```bash
chmod +x check.sh
```

### motd.txt (v1.0)

```
Willkommen in der Admin Toolbox!
Erstellt von: dci-student
Version: 1.0
```

### Verzeichnis-Übersicht

```bash
ls -la
# -rwxrwxr-x  check.sh   (ausführbar ✅)
# -rw-rw-r--  motd.txt
```

---

## Aufgabe 4 — Dockerfile erstellen

```dockerfile
FROM alpine:latest
RUN apk add --no-cache curl
COPY check.sh /usr/local/bin/check.sh
COPY motd.txt /etc/motd.txt
CMD ["/usr/local/bin/check.sh"]
```

**Jede Anweisung erklärt:**

| Anweisung | Funktion | Layer |
|---|---|---|
| `FROM alpine:latest` | Basis-Image festlegen | Layer 1 (geerbt) |
| `RUN apk add --no-cache curl` | curl installieren | Layer 2 (neu) |
| `COPY check.sh ...` | Script ins Image kopieren | Layer 3 (neu) |
| `COPY motd.txt ...` | MOTD-Datei kopieren | Layer 4 (neu) |
| `CMD [...]` | Standardbefehl beim Start | Konfiguration (0B) |

**Warum `--no-cache` bei apk?**
```
→ apk speichert normalerweise einen lokalen Package-Cache
→ --no-cache → kein Cache gespeichert → kleineres Image
→ Best Practice für Production Images
```

**Warum Array-Format für CMD?**
```
CMD ["/usr/local/bin/check.sh"]   ← bevorzugt (exec form)
CMD /usr/local/bin/check.sh       ← funktioniert auch (shell form)

Array-Format startet den Prozess direkt (kein Shell-Wrapper)
→ Signale werden korrekt weitergeleitet (wichtig für graceful shutdown)
```

---

## Aufgabe 5 — Image bauen und testen

### Build v1.0

```bash
docker build -t admin-toolbox:1.0 .
```

**Build-Output:**
```
[+] Building 1.2s (9/9) FINISHED

[1/4] FROM docker.io/library/alpine:latest     → aus Cache (0.0s)
[2/4] RUN apk add --no-cache curl              → curl installiert (0.9s)
[3/4] COPY check.sh /usr/local/bin/check.sh   → kopiert (0.0s)
[4/4] COPY motd.txt /etc/motd.txt             → kopiert (0.0s)
```

### Container starten und testen

```bash
docker run --rm admin-toolbox:1.0
```

**Output:**
```
================================
  Admin Toolbox - System Check  
================================
Hostname    : fa0f83b14a44
Datum       : Sat Apr 25 16:05:37 UTC 2026
OS Info     : Alpine Linux v3.23
--------------------------------
Willkommen in der Admin Toolbox!
Erstellt von: dci-student
Version: 1.0
================================
```

**`--rm` erklärt:**
```
→ Container wird nach Beenden automatisch gelöscht
→ Kein manuelles docker rm nötig
→ Ideal für einmalige Ausführungen (Skripte, Tests)
```

---

## Aufgabe 6 — Änderung testen und Build-Verhalten beobachten

### motd.txt auf v1.1 aktualisieren

```
Willkommen in der Admin Toolbox!
Erstellt von: dci-student
Version: 1.1 - Aktualisiert!
```

### Build v1.1

```bash
docker build -t admin-toolbox:1.1 .
```

**Build-Output v1.1:**
```
[+] Building 0.1s (9/9) FINISHED   ← 12x schneller als v1.0!

[1/4] FROM alpine:latest            → CACHED (0.0s) ✅
[2/4] RUN apk add --no-cache curl  → CACHED (0.0s) ✅ curl NICHT neu installiert!
[3/4] COPY check.sh ...            → CACHED (0.0s) ✅ check.sh nicht geändert
[4/4] COPY motd.txt ...            → NEU    (0.0s) ← nur dieser Layer neu
```

### Layer Caching — Das Prinzip

```
Docker prüft jeden Layer von oben nach unten:

Hat sich etwas geändert?
    → Ja  → diesen Layer + ALLE folgenden neu bauen
    → Nein → aus Cache laden

motd.txt geändert → nur Layer 4 neu → Layer 1, 2, 3 aus Cache
→ curl wird NICHT neu heruntergeladen → spart Zeit und Bandbreite!
```

**Vergleich v1.0 vs v1.1:**
```
v1.0 Build : 1.2s  (alles neu)
v1.1 Build : 0.1s  (fast alles aus Cache)
```

---

## Erweiterungsaufgabe 3 — CMD überschreiben

### Mit Standard CMD

```bash
docker run --rm admin-toolbox:1.1
# → check.sh wird automatisch ausgeführt
```

### CMD überschreiben

```bash
docker run --rm -it admin-toolbox:1.1 /bin/sh
```

```
/ # ls /usr/local/bin/
check.sh                    ← COPY hat funktioniert ✅

/ # cat /etc/motd.txt
Willkommen in der Admin Toolbox!
Erstellt von: dci-student
Version: 1.1 - Aktualisiert!  ← korrekte Version ✅

/ # exit
```

**CMD vs überschriebenes Kommando:**

| Start | Verhalten |
|---|---|
| `docker run admin-toolbox:1.1` | CMD aus Dockerfile → check.sh startet |
| `docker run admin-toolbox:1.1 /bin/sh` | CMD ignoriert → Shell geöffnet |
| `docker run admin-toolbox:1.1 curl google.com` | CMD ignoriert → curl ausgeführt |

```
→ CMD = Standardverhalten (kann immer überschrieben werden)
→ Nützlich für: Debugging, manuelle Inspektion des Containers
→ In Produktion: CMD wird selten überschrieben
```

---

## Beobachtungen: beobachtungen.md

### Was ist ein Docker Image?

```
→ Eine geordnete, unveränderliche Sammlung von Layers
→ Jede Dockerfile-Anweisung = ein neuer Layer
→ Layers sind read-only und wiederverwendbar
→ Container = Image-Layers + beschreibbarer Layer
→ Images sind portabel: überall gleich (lokal, AWS, Azure, GCP)
```

### Layer Caching — Warum Reihenfolge wichtig ist

```
GUTE Reihenfolge (selten änderndes oben):
FROM alpine
RUN apk add curl          ← ändert sich selten → bleibt im Cache
COPY check.sh ...         ← ändert sich manchmal
COPY motd.txt ...         ← ändert sich oft → ganz unten

SCHLECHTE Reihenfolge:
FROM alpine
COPY motd.txt ...         ← ändert sich oft → invalidiert ALLE folgenden
RUN apk add curl          ← wird bei jeder motd-Änderung neu installiert!
```

---

## Reflexion

**Welche Dockerfile-Anweisungen habe ich praktisch eingesetzt?**
```
FROM  → Basis-Image wählen (alpine = 8.45MB vs ubuntu = 78.1MB)
RUN   → Pakete installieren (apk add curl)
COPY  → Dateien ins Image kopieren (check.sh, motd.txt)
CMD   → Standardbefehl beim Container-Start (überschreibbar)
```

**Warum ein Custom Image für Admin-Aufgaben?**
```
→ Alle nötigen Tools in einem Image gebündelt
→ Überall gleich (lokal, CI/CD, Server)
→ Versionierbar (admin-toolbox:1.0, :1.1...)
→ Kein manuelles Setup auf jedem Server nötig
→ In AWS ECS/EKS: Container startet sofort mit allem was nötig ist
```

**Verbindung zu Cloud-Konzepten:**
```
→ AWS ECR (Elastic Container Registry) → Docker Images in AWS speichern
→ AWS ECS → Admin-Toolbox als scheduled Task ausführen
→ CI/CD Pipeline: Code ändern → docker build → docker push → deploy
→ Layer Caching: schnellere Build-Pipelines in GitHub Actions / Jenkins
```
