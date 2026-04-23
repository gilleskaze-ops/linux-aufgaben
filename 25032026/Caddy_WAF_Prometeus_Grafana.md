# Secure Dual-Proxy Setup: Caddy WAF & Grafana/Prometheus
**Datum:** 25.03.2026  
**Benutzer:** dci-student

> **Ziel:** Aufbau einer sicheren Monitoring-Infrastruktur mit einem Caddy-Server als Dual-Proxy (WAF + Forward Proxy) vor einem isolierten Backend mit Grafana und Prometheus.

---

## Architektur & Netzwerklayout

```
Internet
    ↓
Proxy-Server (10.0.0.2) — öffentliche IP
    ├── Reverse Proxy → schützt Grafana mit Coraza WAF (OWASP CRS)
    └── Forward Proxy → erlaubt Backend HTTP/HTTPS für Updates (Port 3128)
         ↓
Backend-Server (10.0.0.3) — nur intern erreichbar
    ├── Grafana  → Port 3000 (nur intern, 10.0.0.3)
    └── Prometheus → Port 9090 (nur localhost, 127.0.0.1)

Privates Subnetz: 10.0.0.0/16
```

**Warum diese Architektur?**
```
→ Backend-Server hat KEINE öffentliche IP → nicht direkt angreifbar
→ Alle eingehenden Anfragen gehen durch Caddy + WAF → gefiltert
→ Backend kann dennoch Updates laden → über Forward Proxy
→ Grafana ist von außen erreichbar → aber nur durch den WAF-Filter
→ Das ist Defense in Depth — mehrere Sicherheitsschichten
```

---

## Teil 1: Proxy-Server einrichten (10.0.0.2)

### 1. Vorbereitungen und Kompilierung

**Warum selbst kompilieren?**
```
→ Standard-Caddy hat KEIN WAF-Modul (Coraza)
→ Standard-Caddy hat KEINEN Forward Proxy
→ Wir brauchen beide Module → müssen Caddy selbst bauen
→ xcaddy = Build-Tool das Caddy mit extra Modulen kompiliert
```

```bash
# System-Pakete aktualisieren und Abhängigkeiten installieren
# golang-go → Go-Programmiersprache (Caddy ist in Go geschrieben)
# curl → zum Herunterladen von Dateien
# git → für Quellcode-Downloads
# ufw → Firewall-Tool (Uncomplicated Firewall)
sudo apt update
sudo apt install -y golang-go curl git ufw

# xcaddy installieren — OHNE sudo!
# → xcaddy wird im Home-Verzeichnis des Users installiert
# → sudo würde es als root installieren → Sicherheitsrisiko
# → go install lädt und kompiliert xcaddy automatisch
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Caddy mit beiden Modulen kompilieren — OHNE sudo!
# --with github.com/corazawaf/coraza-caddy/v2 → WAF-Modul (Web Application Firewall)
# --with github.com/caddyserver/forwardproxy@caddy2 → Forward Proxy Modul
# → xcaddy lädt den Caddy-Quellcode + die Module und kompiliert alles zusammen
# → Ergebnis: eine einzige Binärdatei "caddy" im aktuellen Verzeichnis
~/go/bin/xcaddy build --with github.com/corazawaf/coraza-caddy/v2 --with github.com/caddyserver/forwardproxy@caddy2

# Fertige Binärdatei ins System integrieren
# mv → verschiebt die kompilierte Datei nach /usr/bin/ (systemweiter Pfad)
# chown root:root → Eigentümer ist root (Sicherheit)
# chmod 755 → root kann lesen/schreiben/ausführen, alle anderen nur lesen/ausführen
sudo mv caddy /usr/bin/caddy
sudo chown root:root /usr/bin/caddy
sudo chmod 755 /usr/bin/caddy
```

---

### 2. System-Benutzer und Ordner anlegen

**Warum einen eigenen Benutzer für Caddy?**
```
→ Least Privilege Prinzip! (wie wir in IAM gelernt haben)
→ Caddy braucht KEINE root-Rechte zum Laufen
→ Wenn Caddy kompromittiert wird → Angreifer hat nur caddy-Rechte
→ Nicht root-Rechte → viel geringerer Schaden
→ --system → kein Login möglich (kein Passwort, kein Shell-Login)
```

```bash
# Systemgruppe "caddy" erstellen
# --system → Gruppe für Systemdienste (niedrige GID-Nummer)
sudo groupadd --system caddy

# Systembenutzer "caddy" erstellen
# --system → kein echter Benutzer, nur für Dienste
# --gid caddy → gehört zur Gruppe "caddy"
# --create-home → eigenes Home-Verzeichnis (für TLS-Zertifikate)
# --home-dir /var/lib/caddy → wo das Home-Verzeichnis ist
# --shell /usr/sbin/nologin → KEIN Login möglich! (Sicherheit)
sudo useradd --system --gid caddy --create-home --home-dir /var/lib/caddy --shell /usr/sbin/nologin caddy

# Verzeichnisse erstellen
# /etc/caddy/coraza → für WAF-Konfigurationsdateien
# /var/log/caddy → für Log-Dateien (WAF-Audit, Access-Logs)
# -p → erstellt auch übergeordnete Verzeichnisse falls nötig
sudo mkdir -p /etc/caddy/coraza /var/log/caddy

# Log-Verzeichnis dem caddy-Benutzer geben
# -R → rekursiv (alle Dateien und Unterordner)
# → Caddy muss Logs schreiben können → braucht Schreibrechte
sudo chown -R caddy:caddy /var/log/caddy
```

---

### 3. Systemd Service anlegen

**Was ist ein Systemd Service?**
```
→ Systemd verwaltet alle Dienste auf Linux
→ Mit einer .service Datei definieren wir:
   - Wie Caddy gestartet wird
   - Als welcher Benutzer
   - Was bei Neustart passiert
→ systemctl enable → Caddy startet automatisch beim Boot
→ systemctl start → Caddy startet sofort
```

```bash
# Service-Datei erstellen mit Heredoc (cat << 'EOF' ... EOF)
# → schreibt alles zwischen EOF und EOF direkt in die Datei
cat << 'EOF' | sudo tee /etc/systemd/system/caddy.service
[Unit]
# Beschreibung des Dienstes
Description=Caddy
# Caddy startet NACH dem Netzwerk (braucht Netzwerk für TLS)
After=network.target network-online.target
Requires=network-online.target

[Service]
# Type=notify → Caddy meldet systemd wenn es bereit ist
Type=notify
# Als caddy-Benutzer laufen (nicht root!)
User=caddy
Group=caddy
# Startbefehl: caddy run mit Konfigurationsdatei
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
# Reload-Befehl (kein Neustart nötig bei Konfigurationsänderung)
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile --force
# 5 Sekunden warten beim Stoppen
TimeoutStopSec=5s
# Maximale Anzahl offener Dateien (wichtig für viele Verbindungen)
LimitNOFILE=1048576
LimitNPROC=512
# Sicherheits-Sandboxing:
# PrivateTmp → eigenes /tmp Verzeichnis (andere Prozesse sehen es nicht)
PrivateTmp=true
# ProtectSystem → /usr und /boot sind read-only für caddy
ProtectSystem=full
# CAP_NET_BIND_SERVICE → erlaubt Caddy Port 80/443 zu öffnen (normalerweise nur root)
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
# Dienst wird im normalen Betriebsmodus gestartet
WantedBy=multi-user.target
EOF

# Systemd über neue Service-Datei informieren
# → muss nach jeder Änderung an .service Dateien ausgeführt werden
sudo systemctl daemon-reload
```

---

### 4. Coraza WAF Grundkonfiguration

**Was ist Coraza WAF?**
```
→ WAF = Web Application Firewall (OSI Schicht 7)
→ Analysiert den INHALT von HTTP-Anfragen
→ Erkennt Angriffe: SQL Injection, XSS, Path Traversal...
→ OWASP CRS = Open Web Application Security Project Core Rule Set
→ Industriestandard für WAF-Regeln (kostenlos, open source)
```

```bash
cat << 'EOF' | sudo tee /etc/caddy/coraza/coraza.conf
# WAF-Engine aktivieren (On = aktiv, Detection Only = nur loggen)
SecRuleEngine On

# Request Body analysieren (POST-Daten, JSON, Formulare)
SecRequestBodyAccess On
# Maximale Body-Größe: 13MB (schützt vor Memory-Exhaustion)
SecRequestBodyLimit 13107200
# Maximale Body-Größe ohne Datei-Uploads: 128KB
SecRequestBodyNoFilesLimit 131072

# Response Body analysieren (schützt vor Datenlecks)
SecResponseBodyAccess On
# Maximale Response-Größe die analysiert wird: 512KB
SecResponseBodyLimit 524288
# Nur diese MIME-Types analysieren (HTML, Text, XML)
SecResponseBodyMimeType text/plain text/html text/xml

# Audit-Log Einstellungen
# RelevantOnly → nur verdächtige Anfragen loggen (nicht alles)
SecAuditEngine RelevantOnly
# Nur 4xx (außer 404) und 5xx Fehler loggen
SecAuditLogRelevantStatus "^(?:5|4(?!04))"
# Welche Log-Teile gespeichert werden (A=Request, B=Request Headers, etc.)
SecAuditLogParts ABIJDEFHZ
# Serial → Logs sequenziell in eine Datei schreiben
SecAuditLogType Serial
# Pfad zur Audit-Log-Datei
SecAuditLog /var/log/caddy/coraza-audit.log
EOF
```

---

### 5. Inkompatible WAF-Regel patchen

**Warum ist dieser Patch nötig?**
```
→ Das OWASP CRS enthält die Direktive "SecRequestBodyJsonDepthLimit"
→ Diese Direktive wird vom Coraza-Caddy-Plugin noch NICHT unterstützt
→ Ohne diesen Patch → Caddy stürzt beim Start ab
→ sed -i → bearbeitet die Datei direkt (in-place)
→ 's/ORIGINAL/ERSATZ/g' → ersetzt alle Vorkommen
→ Wir kommentieren die Zeile aus → # davor → Caddy ignoriert sie
```

```bash
# Alle Zeilen mit "SecRequestBodyJsonDepthLimit" auskommentieren
# 's/.../# .../g' → fügt # am Anfang jeder gefundenen Zeile ein
sudo sed -i 's/SecRequestBodyJsonDepthLimit/# SecRequestBodyJsonDepthLimit/g' /etc/caddy/coraza/coraza.conf
```

---

### 6. Caddyfile konfigurieren

**Was macht diese Konfiguration?**
```
Caddyfile = Caddy's Konfigurationssprache (einfacher als nginx/Apache)

Zwei Blöcke:
1. deine-domain.de → HTTPS (Port 443, automatisches TLS von Let's Encrypt)
   → WAF filtert alle Anfragen
   → Dann weitergeleitet an Grafana (10.0.0.3:3000)

2. http://:3128 → Forward Proxy (nur für internes Netz)
   → Nur IPs aus 10.0.0.0/16 dürfen ihn nutzen
   → Alle anderen → abort (Verbindung sofort trennen)
```

```bash
# WICHTIG: "deine-domain.de" durch echte Domain ersetzen!
cat << 'EOF' | sudo tee /etc/caddy/Caddyfile
{
    # WAF wird VOR allem anderen ausgeführt
    order coraza_waf first
    # Forward Proxy vor dem normalen File-Server
    order forward_proxy before file_server
}

# Block 1: HTTPS Reverse Proxy mit WAF für Grafana
deine-domain.de {
    # WAF-Konfiguration
    coraza_waf {
        # OWASP Core Rule Set laden (Industriestandard)
        load_owasp_crs
        # Eigene Coraza-Konfiguration einbinden
        directives `
            Include /etc/caddy/coraza/coraza.conf
        `
    }
    # Weiterleitung an Grafana auf dem Backend-Server
    # → Anfragen kommen von außen → Caddy filtert → leitet weiter
    reverse_proxy 10.0.0.3:3000
}

# Block 2: Forward Proxy für internes Netz (Port 3128)
http://:3128 {
    # Nur anfragen aus dem privaten Subnetz erlauben
    @internal {
        remote_ip 10.0.0.0/16
    }
    # Interne IPs → Forward Proxy aktivieren
    handle @internal {
        forward_proxy {
            hide_ip   # Client-IP verstecken (Proxy-Anonymität)
            hide_via  # Via-Header verstecken (Proxy nicht erkennbar)
        }
    }
    # Alle anderen IPs → Verbindung sofort trennen
    handle {
        abort
    }
}
EOF
```

---

### 7. Firewall & Dienst starten

**Warum diese Firewall-Regeln?**
```
→ ufw = Uncomplicated Firewall (einfache Verwaltung von iptables)
→ Standardmäßig: alles blockieren
→ Wir öffnen nur was nötig ist (Least Privilege für Netzwerk!)

Erlaubte Ports:
→ SSH (22)    → für Verwaltung
→ 80/443      → HTTP/HTTPS für Caddy und TLS-Challenge
→ 3128        → nur aus dem internen Netz (10.0.0.0/16)
```

```bash
# SSH erlauben (WICHTIG: vorher erlauben sonst sperrt man sich aus!)
sudo ufw allow ssh

# HTTP (80) und HTTPS (443) öffnen
# → 80 für Let's Encrypt TLS-Challenge (automatisches Zertifikat)
# → 443 für HTTPS-Traffic
sudo ufw allow 80,443/tcp

# Forward Proxy Port NUR für internes Netz erlauben
# → from 10.0.0.0/16 → nur Pakete aus diesem Subnetz
# → to any port 3128 → auf Port 3128
sudo ufw allow from 10.0.0.0/16 to any port 3128

# Firewall aktivieren
sudo ufw enable

# Caddy aktivieren (startet beim Boot) und sofort starten
# --now → kombiniert enable + start in einem Befehl
sudo systemctl enable --now caddy
```

---

## Teil 2: Backend-Server einrichten (10.0.0.3)

### 1. APT-Proxy konfigurieren

**Warum ein APT-Proxy?**
```
→ Backend-Server hat KEINE direkte Internetverbindung (isoliert!)
→ Für Updates braucht er aber Internetzugriff
→ Lösung: apt nutzt den Forward Proxy auf 10.0.0.2:3128
→ Alle apt update / apt install Befehle gehen durch den Proxy
→ Sicherheit bleibt erhalten (Backend hat keine direkte Verbindung)
```

```bash
# Variablen definieren (verhindert Formatierungsfehler)
PRX_PROTO="http"
PRX_IP="10.0.0.2"

# APT-Proxy-Konfiguration schreiben
# → apt liest diese Datei und nutzt den Proxy für alle Downloads
cat << EOF | sudo tee /etc/apt/apt.conf.d/00proxy
Acquire::http::Proxy "${PRX_PROTO}://${PRX_IP}:3128/";
Acquire::https::Proxy "${PRX_PROTO}://${PRX_IP}:3128/";
EOF
```

---

### 2. Grafana installieren

**Was ist Grafana?**
```
→ Open-Source Visualisierungsplattform
→ Verbindet sich mit Datenquellen (Prometheus, InfluxDB, SQL...)
→ Erstellt Dashboards mit Graphen, Gauges, Alerts
→ Hier: visualisiert Server-Metriken von Prometheus
```

```bash
sudo apt update
sudo apt install -y apt-transport-https software-properties-common wget curl

# Variablen für URLs definieren
PRX_PROTO="http"
PRX_IP="10.0.0.2"
GFN_PROTO="https"
GFN_DOM="apt.grafana.com"

# Grafana GPG-Schlüssel herunterladen (über den Proxy!)
# curl -x → Proxy angeben
# -fsSL → fail silently, silent mode, follow redirects
# gpg --dearmor → konvertiert ASCII-Key in binäres Format
# -o → Ausgabedatei
curl -x ${PRX_PROTO}://${PRX_IP}:3128 -fsSL ${GFN_PROTO}://${GFN_DOM}/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/grafana.gpg

# Grafana-Repository zur apt-Quellenliste hinzufügen
# signed-by → nur Pakete die mit diesem Key signiert sind akzeptieren
# stable main → stabile Version
echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] ${GFN_PROTO}://${GFN_DOM} stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

sudo apt update
sudo apt install -y grafana
```

---

### 3. Grafana konfigurieren

**Warum an die interne IP binden?**
```
→ http_addr = 10.0.0.3 → Grafana hört NUR auf der internen IP
→ Von außen direkt NICHT erreichbar (kein Port nach außen offen)
→ Nur über Caddy (10.0.0.2) erreichbar → WAF-geschützt
→ root_url → wichtig für korrekte Redirect-URLs in Grafana
```

Öffne `/etc/grafana/grafana.ini` und ändere:

```ini
[server]
# Nur auf interne IP binden (nicht 0.0.0.0 → nicht überall erreichbar)
http_addr = 10.0.0.3
http_port = 3000
# Deine Domain (für korrekte Links in Grafana)
domain = deine-domain.de
# Vollständige URL (wichtig für OAuth, Alerts, Sharing)
root_url = https://%(domain)s/
```

```bash
# Grafana neu starten damit Konfiguration aktiv wird
sudo systemctl restart grafana-server
```

---

### 4. Prometheus absichern

**Was ist Prometheus?**
```
→ Open-Source Monitoring-System
→ Sammelt Metriken von Servern und Anwendungen
→ Speichert Zeitreihen-Daten
→ Grafana visualisiert diese Daten
```

**Warum nur auf localhost binden?**
```
→ Prometheus hat KEINE Authentifizierung in der Standardkonfiguration
→ Wäre auf 0.0.0.0 → jeder im Netz könnte alle Metriken sehen
→ Auf 127.0.0.1 → nur lokale Prozesse können zugreifen
→ Grafana läuft auf demselben Server → kann localhost:9090 erreichen
→ Sicherheit: Least Privilege für Netzwerk-Bindings
```

Öffne `/etc/default/prometheus` und setze:

```text
ARGS="--web.listen-address=\"127.0.0.1:9090\""
```

```bash
# Prometheus neu starten
sudo systemctl restart prometheus
```

---

### 5. Node Exporter installieren

**Was ist Node Exporter?**
```
→ Prometheus-Plugin das Server-Metriken sammelt:
   - CPU-Auslastung
   - RAM-Nutzung
   - Disk I/O
   - Netzwerk-Traffic
   - und vieles mehr
→ Prometheus scraped Node Exporter alle X Sekunden
→ Daten landen in Prometheus → Grafana visualisiert sie
```

```bash
# Node Exporter installieren
# → startet automatisch als Systemdienst
# → läuft standardmäßig auf Port 9100 (nur localhost)
sudo apt install prometheus-node-exporter
```

---

## Teil 3: Grafana konfigurieren

### 1. Prometheus als Datenquelle hinzufügen

```
1. Browser → https://deine-domain.de
2. Login: admin / admin (beim ersten Login Passwort ändern!)
3. Linke Seitenleiste → Connections → Data sources
4. Add data source → Prometheus wählen
5. Prometheus server URL: http://127.0.0.1:9090
   → localhost weil Grafana und Prometheus auf demselben Server laufen
6. Save & test → grüner Haken = erfolgreich
```

---

### 2. Dashboard importieren (Offline-Methode)

**Warum Offline-Import?**
```
→ Backend-Server hat keinen direkten Internetzugriff
→ Grafana kann Dashboard-IDs nicht direkt von grafana.com laden
→ Lösung: JSON auf lokalem PC herunterladen → in Grafana hochladen
```

```
1. Auf deinem lokalen PC (mit Internet):
   → https://grafana.com/grafana/dashboards/1860
   → "Download JSON" klicken → Datei speichern

2. In Grafana:
   → Dashboards → Import
   → "Upload JSON file" → heruntergeladene Datei wählen
   → Oder JSON-Inhalt in "Import via panel json" einfügen

3. Datenquelle zuweisen:
   → Im Dropdown: Prometheus auswählen

4. Import klicken → Dashboard ist sofort verfügbar
```

---

## Zusammenfassung der Sicherheitskonzepte

```
Defense in Depth (mehrere Sicherheitsschichten):

Layer 1: Netzwerk (ufw Firewall)
→ Nur Port 22, 80, 443 und 3128 (nur intern) offen

Layer 2: WAF (Coraza + OWASP CRS)
→ HTTP-Anfragen auf Angriffsmuster prüfen
→ SQL Injection, XSS, Path Traversal blockieren

Layer 3: Netzwerk-Isolation
→ Backend hat keine öffentliche IP
→ Nur über Proxy erreichbar

Layer 4: Service-Isolation
→ Grafana: nur auf 10.0.0.3 (nicht 0.0.0.0)
→ Prometheus: nur auf 127.0.0.1 (nur localhost)

Layer 5: Least Privilege
→ Caddy läuft als caddy-User (nicht root)
→ Kein Login für caddy-User möglich

Layer 6: Audit Logging
→ WAF loggt verdächtige Anfragen
→ /var/log/caddy/coraza-audit.log
```

**Verbindung zu Cloud-Konzepten:**
```
Diese Architektur spiegelt exakt AWS-Best-Practices wider:
→ Caddy (10.0.0.2) ≈ AWS Application Load Balancer + WAF
→ Backend (10.0.0.3) ≈ EC2 in privatem Subnet
→ Forward Proxy ≈ AWS NAT Gateway
→ ufw Regeln ≈ Security Groups + NACLs
→ Coraza WAF ≈ AWS WAF mit OWASP Managed Rules
```
