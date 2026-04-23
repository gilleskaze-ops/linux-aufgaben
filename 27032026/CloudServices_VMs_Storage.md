# Aufgabe: Cloud Services, Virtuelle Maschinen & Speicherarten
**Datum:** 27.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — Cloud Services

### Was ist ein Cloud Service?

Ein Cloud Service ist eine IT-Leistung (Rechenleistung, Speicher, Software, Plattform) die **über das Internet on-demand** bereitgestellt wird — ohne eigene Hardware kaufen oder betreiben zu müssen.

**Eigenschaften die einen Cloud Service auszeichnen:**
```
→ On-demand verfügbar   → sofort nutzbar, kein Warten auf Hardware-Lieferung
→ Pay-per-use           → nur zahlen was wirklich genutzt wird
→ Skalierbar            → sofort mehr oder weniger Ressourcen
→ Managed               → Anbieter kümmert sich um Wartung, Updates, Verfügbarkeit
→ Netzwerk-zugänglich   → von überall über Internet erreichbar
```

**Unterschied zu traditioneller IT:**

| Aspekt | Traditionell (On-premise) | Cloud Service |
|---|---|---|
| Beschaffung | Wochen/Monate | Minuten |
| Kosten | Hohe Anfangsinvestition (CapEx) | Laufende Kosten (OpEx) |
| Skalierung | Neue Hardware kaufen | Slider verschieben |
| Wartung | Eigenes IT-Team | Anbieter übernimmt |
| Verfügbarkeit | Abhängig von eigenem RZ | SLA-garantiert (99.99%) |

---

### Cloud Service Kategorien

#### IaaS — Infrastructure as a Service
```
Definition : Rohe Infrastruktur mieten (Server, Netzwerk, Speicher)
Kontrolle  : Du verwaltest OS, Middleware, Apps, Daten
Anbieter   : verwaltet Hardware, Hypervisor, Rechenzentrum

Beispiele:
→ AWS EC2        → virtuelle Server on-demand
→ AWS S3         → unlimitierter Objekt-Speicher
→ Azure VMs      → virtuelle Maschinen
→ GCP Compute Engine → VMs in Googles Infrastruktur
```

#### PaaS — Platform as a Service
```
Definition : Entwicklungsplattform mieten — nur Code schreiben
Kontrolle  : Du verwaltest nur App und Daten
Anbieter   : verwaltet OS, Runtime, Middleware, Hardware

Beispiele:
→ AWS Elastic Beanstalk → Web-App deployen ohne Server verwalten
→ AWS RDS               → verwaltete Datenbank (MySQL, PostgreSQL)
→ Google App Engine     → Anwendungen deployen ohne Infrastruktur
→ Heroku                → einfaches App-Deployment für Entwickler
```

#### SaaS — Software as a Service
```
Definition : Fertige Software über Browser/App nutzen
Kontrolle  : Du verwaltest nur deine Daten und Einstellungen
Anbieter   : verwaltet alles andere

Beispiele:
→ Gmail / Google Workspace → E-Mail und Produktivität
→ Microsoft Office 365     → Word, Excel, PowerPoint in der Cloud
→ Salesforce               → CRM-System
→ Slack                    → Team-Kommunikation
```

---

### 3 wichtigste Vorteile von Cloud Services

```
1. Kosteneffizienz (OpEx statt CapEx)
   → Keine millionenschwere Hardware-Investition
   → Nur zahlen was genutzt wird
   → Kein Geld für Leerlauf-Server verschwenden

2. Agilität und Time-to-Market
   → Neue Infrastruktur in Minuten statt Monaten
   → Schneller experimentieren, schneller auf den Markt
   → Start-ups können sofort mit Enterprise-Infrastruktur starten

3. Globale Skalierbarkeit
   → Von 10 auf 10.000 Nutzer ohne Infrastruktur-Umbau
   → Automatische Skalierung bei Traffic-Spitzen (Black Friday)
   → Globale Reichweite durch weltweite Rechenzentren
```

---

## Aufgabe 2 — Virtuelle Maschinen

### Das Konzept der Virtualisierung

**Was ist Virtualisierung?**
```
→ Eine physische Hardware-Ressource in mehrere virtuelle aufteilen
→ Ein physischer Server → viele virtuelle Server
→ Jede VM "denkt" sie hat eigene Hardware → in Wirklichkeit geteilt
→ Isolation: VMs sehen sich gegenseitig nicht
```

**Was ist ein Hypervisor?**
```
→ Software-Schicht zwischen Hardware und VMs
→ Verwaltet und teilt physische Ressourcen auf VMs auf
→ Sorgt für Isolation zwischen VMs

Zwei Typen:
Type 1 (Bare Metal) → direkt auf Hardware installiert
                      → KVM (Linux), VMware ESXi, Hyper-V
                      → Verwendet in AWS, Azure, GCP Rechenzentren

Type 2 (Hosted)     → auf bestehendem OS installiert
                      → VirtualBox, VMware Workstation
                      → Für Desktop-Virtualisierung
```

**Visualisierung:**
```
Physischer Server (z.B. 128 vCPU, 512GB RAM, 10TB SSD)
    ↓
Hypervisor (KVM)
    ├── VM 1: 4 vCPU, 8GB RAM, 100GB → Ubuntu + Nginx
    ├── VM 2: 8 vCPU, 16GB RAM, 500GB → Windows + SQL Server
    ├── VM 3: 2 vCPU, 4GB RAM, 50GB → Ubuntu + Node.js
    └── VM 4: 16 vCPU, 64GB RAM, 1TB → Ubuntu + ML Training
```

---

### VM vs Physischer Server

| Aspekt | Physischer Server | Virtuelle Maschine |
|---|---|---|
| Beschaffungszeit | Wochen/Monate | Minuten |
| Kosten | Hohe Anfangsinvestition | Pay-per-use |
| Skalierung | Neue Hardware kaufen | Größe anpassen |
| Ausfallsicherheit | Single Point of Failure | Migration zu anderem Host |
| Ressourcennutzung | Oft unter 20% ausgelastet | Effizienter durch Sharing |
| Snapshot/Backup | Komplex | Einfach (in Sekunden) |
| Portabilität | Nicht möglich | VM-Image kopierbar |

**Vorteile von VMs in der Cloud:**
```
✅ Flexibilität    → Größe jederzeit anpassen (Scale up/down)
✅ Skalierbarkeit  → Schnell neue VMs starten (Auto Scaling)
✅ Snapshots       → VM-Zustand in Sekunden sichern und wiederherstellen
✅ Isolation       → VMs voneinander isoliert (Sicherheit)
✅ Portabilität    → VM-Image zwischen Regionen kopieren
✅ Kosteneffizienz → Nur für Laufzeit bezahlen
```

---

### 3 typische Anwendungsfälle für VMs

**1. Web-Server und API-Backends:**
```
→ Warum VM?: Volle OS-Kontrolle, spezifische Konfiguration nötig
→ Beispiel: LAMP-Stack (Linux, Apache, MySQL, PHP) auf EC2
→ Vorteil: Auto Scaling Group → bei Traffic automatisch mehr VMs
```

**2. Lift & Shift Migration:**
```
→ Warum VM?: On-premise Server direkt in Cloud migrieren
→ Beispiel: Windows Server mit Legacy-Anwendung → Azure VM
→ Vorteil: Keine Code-Änderungen nötig, sofortige Cloud-Vorteile
```

**3. Entwicklungs- und Testumgebungen:**
```
→ Warum VM?: Isolierte Umgebung für jeden Entwickler
→ Beispiel: Dev-VM starten → testen → stoppen (nur Laufzeit bezahlen)
→ Vorteil: Prod-identische Umgebung, kein "works on my machine"
```

---

## Aufgabe 3 — Speicherarten in der Cloud

### Dateispeicher (File Storage)

**Definition und Funktionsweise:**
```
→ Netzwerk-Dateisystem mit klassischer Ordner-Hierarchie
→ Zugriff über NFS (Linux) oder SMB (Windows) Protokoll
→ Mehrere Server können GLEICHZEITIG auf dieselben Dateien zugreifen
→ Verhält sich wie ein freigegebenes Netzlaufwerk
```

**Datenorganisation:**
```
/data/
    ├── /config/
    │       ├── app.conf
    │       └── db.conf
    ├── /logs/
    │       └── application.log
    └── /media/
            └── uploads/
```

**Zwei Anwendungsbeispiele:**
```
1. WordPress mit mehreren Web-Servern (Auto Scaling Group)
   → Alle Server müssen auf dieselben Upload-Dateien zugreifen
   → EFS mounten → alle Server sehen denselben /var/www/uploads/
   → Ohne File Storage: jeder Server hätte eigene Dateien → inkonsistent

2. Machine Learning Training
   → Viele GPU-Instanzen lesen gleichzeitig Trainingsdaten
   → EFS mounten → alle GPU-Nodes greifen auf dieselben Datasets zu
   → Ohne File Storage: Daten müssten auf jede Instanz kopiert werden
```

**Cloud Services:** AWS EFS | Azure Files | GCP Filestore

---

### Blockspeicher (Block Storage)

**Definition und Funktionsweise:**
```
→ Speichert Daten in fixen Blöcken (wie eine physische Festplatte)
→ Wird direkt an eine VM angehängt (wie USB-SSD einstecken)
→ Sehr niedrige Latenz (< 1ms), sehr hohe IOPS
→ Kein direkter Netzwerkzugriff — nur über angehängte VM
```

**Unterschied zu File Storage:**
```
File Storage  → mehrere VMs → gleichzeitiger Zugriff → NFS/SMB Protokoll
Block Storage → eine VM     → exklusiver Zugriff    → direkter Disk-Zugriff
```

**Leistungseigenschaften:**
```
→ IOPS: bis zu 256.000 IOPS (AWS io2 Block Express)
→ Latenz: < 1ms (sub-millisecond)
→ Durchsatz: bis zu 4.000 MB/s
→ Perfekt für transaktionale Workloads (ACID-Datenbanken)
```

**Zwei Anwendungsbeispiele:**
```
1. Produktions-Datenbank (MySQL auf EC2)
   → Datenbank braucht sehr niedrige Latenz für Transaktionen
   → EBS io2 Volume → direkt an EC2 angehängt → < 1ms Latenz
   → Ohne Block Storage: Object Storage wäre zu langsam (ms statt μs)

2. OS-Volume einer VM (Root Volume)
   → Jede EC2 braucht ein Boot-Volume für das OS
   → EBS gp3 Volume → /dev/xvda → Ubuntu/Windows startet darauf
   → Standard für alle VM-Betriebssysteme in der Cloud
```

**Cloud Services:** AWS EBS | Azure Managed Disks | GCP Persistent Disk

---

### Objektspeicher (Object Storage)

**Definition und Funktionsweise:**
```
→ Speichert Daten als "Objekte" (Datei + Metadaten + eindeutige ID)
→ Flache Struktur — kein klassisches Ordner-System
→ Zugriff über HTTP/HTTPS REST API — von überall erreichbar
→ Theoretisch unlimitierte Skalierung (Petabytes problemlos)
```

**Wie Objekte gespeichert werden:**
```
Objekt = {
    data     : die eigentliche Datei (Bild, Video, Backup...)
    metadata : {
        content-type: "image/jpeg",
        size: "2.4MB",
        created: "2026-03-27",
        custom: { "user-id": "12345", "project": "webapp" }
    }
    id       : eindeutige URL (https://bucket.s3.amazonaws.com/foto.jpg)
}
```

**Rolle der Metadaten:**
```
→ Metadaten beschreiben das Objekt ohne es öffnen zu müssen
→ Suche und Filterung über Metadaten möglich
→ Lifecycle Rules basierend auf Metadaten (z.B. nach 30 Tagen archivieren)
→ Versionierung: mehrere Versionen desselben Objekts mit Metadaten
```

**Zwei Anwendungsbeispiele:**
```
1. Media-Storage für Web-Anwendung
   → Millionen von Nutzer-Fotos und Videos speichern
   → S3 → unlimitiert skalierbar, günstig, globaler Zugriff via CDN
   → Ohne Object Storage: Block Storage würde für Petabytes explodieren

2. Data Lake für Analytics und ML
   → Rohdaten (CSV, JSON, Parquet) für BigQuery/Athena speichern
   → S3 → günstigster Speicher für kalte Daten, direkter Athena-Zugriff
   → SQL-Abfragen direkt auf S3-Daten ohne Daten in DB laden
```

**Cloud Services:** AWS S3 | Azure Blob Storage | GCP Cloud Storage

---

### Der richtige Speicher für den richtigen Zweck

**Vergleichstabelle:**

| Aspekt | File Storage | Block Storage | Object Storage |
|---|---|---|---|
| Zugriff | NFS/SMB Protokoll | Direkt (wie Festplatte) | HTTP/HTTPS REST API |
| Gleichzeitige Zugriffe | Mehrere VMs ✅ | 1 VM (meist) | Millionen Clients ✅ |
| Latenz | Niedrig (ms) | Sehr niedrig (< 1ms) | Mittel (ms) |
| Skalierung | Groß (PB) | Begrenzt (64TB) | Unlimitiert (PB) ✅ |
| Struktur | Ordner-Hierarchie | Keine | Flach (kein Ordner) |
| Kosten | Mittel | Teurer | Günstigst ✅ |
| AWS Service | EFS | EBS | S3 |

**Entscheidungslogik:**

```
Frage 1: Brauchen mehrere Server gleichzeitig Zugriff?
    → Ja  → File Storage (EFS, Azure Files)

Frage 2: Brauche ich sehr niedrige Latenz / hohe IOPS?
    → Ja  → Block Storage (EBS, Managed Disks)
    → Typisch für: Datenbanken, OS-Volumes

Frage 3: Viele unstrukturierte Daten / Backups / Media?
    → Ja  → Object Storage (S3, Blob Storage)
    → Günstigste Option, unlimitierte Skalierung
```

---

## Selbstreflexion

**Wichtigste Erkenntnisse:**

```
Cloud Services:
→ Der Hauptvorteil ist nicht Kostenersparnis — es ist Agilität
→ Ein Start-up kann heute mit derselben Infrastruktur starten
  wie Amazon oder Netflix — das war früher undenkbar

Virtuelle Maschinen:
→ Der Hypervisor ist das unsichtbare Herzstück der Cloud
→ Ohne Virtualisierung keine Cloud — es ist die Grundtechnologie

Storage:
→ "Falscher" Storage-Typ = Architektur-Fehler mit Performance-Konsequenzen
→ Eine Datenbank auf Object Storage = viel zu hohe Latenz
→ Media-Dateien auf Block Storage = viel zu teuer
```

**Verbindung zu vorherigen Themen:**
```
→ VMs laufen in VPC Subnets → Security Groups schützen sie (Firewalls)
→ IAM Roles geben VMs Zugriff auf S3 (Least Privilege)
→ Multi-AZ: VMs in verschiedenen AZs + EFS → High Availability
→ Shared Responsibility: AWS sichert S3-Infrastruktur,
  du konfigurierst Bucket Policies korrekt
```
