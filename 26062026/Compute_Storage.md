# Aufgabe: Compute & Storage im Cloud Computing
**Datum:** 26.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Teil 1 — Compute im Cloud Computing

### Was ist Compute?

Compute = **Rechenleistung** — CPU, RAM und GPU die Anwendungen ausführen.

```
On-premise : fester Server → immer bezahlen → egal ob genutzt oder nicht
Cloud      : Rechenleistung mieten → pay-per-use → nur zahlen was genutzt wird
```

**Wichtige Compute-Metriken:**

| Metrik | Bedeutung |
|---|---|
| vCPU | Virtuelle CPU-Kerne |
| RAM (GB) | Arbeitsspeicher |
| IOPS | I/O-Operationen pro Sekunde (Disk-Speed) |
| Netzwerk-Bandbreite | Gbps (Gigabit per second) |
| GPU | Für ML/AI und Grafik-Workloads |

---

### 3 Hauptkategorien von Compute-Services

#### 1. Virtuelle Maschinen (VMs)

**Was ist es?**
```
→ Ein vollständiger Computer der als Software auf einem physischen 
  Server läuft
→ Hypervisor teilt physische Hardware auf mehrere VMs auf
→ Hat eigenes Betriebssystem (Windows, Linux...)
→ Verhält sich exakt wie ein echter physischer Server
```

**Wie funktioniert es?**
```
Physischer Server
    ↓
Hypervisor (KVM, VMware, Xen)
    ├── VM 1: Ubuntu + Nginx + 4 vCPU + 8GB RAM
    ├── VM 2: Windows + IIS + 2 vCPU + 4GB RAM
    └── VM 3: Ubuntu + MySQL + 8 vCPU + 32GB RAM
```

**Wann einsetzen?**
```
✅ Wenn volle OS-Kontrolle nötig ist
✅ Legacy-Anwendungen die spezifisches OS brauchen
✅ Lift & Shift Migration (on-premise Server → Cloud)
✅ Lange laufende Workloads (24/7)
✅ Wenn Anwendungen nicht containerisierbar sind
```

**Cloud Services:** AWS EC2 | Azure Virtual Machines | GCP Compute Engine

---

#### 2. Container (Docker / Kubernetes)

**Was ist es?**
```
→ Isolierte Umgebung die nur die App + ihre Abhängigkeiten enthält
→ Kein eigenes OS — nutzt das OS des Host-Systems
→ Viel leichter als VMs (Megabytes statt Gigabytes)
→ Portabel: läuft überall gleich (lokal, AWS, Azure, GCP)
```

**VM vs Container:**
```
VM        : [App][OS (GB)][Hypervisor][Hardware]
            → schwer, Minuten zum Starten, mehr Ressourcen

Container : [App][Container Runtime][OS][Hardware]
            → leicht, Sekunden zum Starten, effizient
```

**Vorteile:**
```
✅ "Works on my machine" Problem gelöst → überall gleich
✅ Sehr schnell zu starten (Sekunden statt Minuten)
✅ Ressourceneffizienter → mehr Apps auf demselben Server
✅ Perfekt für Microservices-Architektur
✅ CI/CD freundlich (Build → Test → Deploy)
```

**Wann einsetzen?**
```
✅ Microservices Architektur
✅ CI/CD Pipelines
✅ Wenn viele kleine Services deployt werden
✅ Wenn Portabilität zwischen Clouds wichtig ist
```

**Cloud Services:** AWS ECS/EKS | Azure AKS | GCP GKE

---

#### 3. Serverless Computing

**Was ist es?**
```
→ Code ausführen OHNE Server zu verwalten
→ Kein OS-Management, kein Patching, keine Kapazitätsplanung
→ Automatische Skalierung: 0 → Millionen von Anfragen
→ Bezahlung NUR wenn Code ausgeführt wird (pro Millisekunde!)
```

**Vergleich der Verwaltungsebenen:**
```
VM         : Server 24/7 aktiv → immer bezahlen auch wenn nichts passiert
Container  : Cluster verwalten → du kümmerst dich um Nodes/Pods
Serverless : Code hochladen → AWS kümmert sich um alles andere
```

**Typische Trigger:**
```
→ HTTP-Anfrage → Lambda antwortet
→ S3-Upload → Lambda verarbeitet Bild automatisch
→ Timer (Cron) → Lambda läuft täglich um 3 Uhr
→ DynamoDB-Änderung → Lambda reagiert auf Datenbank-Event
```

**Wann einsetzen?**
```
✅ Event-driven Verarbeitung
✅ APIs mit sehr variablem Traffic (0 bis Millionen)
✅ Scheduled Tasks
✅ Kleine, kurzlebige Funktionen
✅ Wenn minimaler Verwaltungsaufwand gewünscht
```

**Cloud Services:** AWS Lambda | Azure Functions | GCP Cloud Functions

---

### Vergleichstabelle: VM vs Container vs Serverless

| Aspekt | VM | Container | Serverless |
|---|---|---|---|
| OS-Kontrolle | Vollständig | Nein | Nein |
| Startzeit | Minuten | Sekunden | Millisekunden |
| Ressourcengröße | Groß (GB) | Klein (MB) | Minimal |
| Skalierung | Manuell/Auto | Auto (Kubernetes) | Vollautomatisch |
| Bezahlung | Laufzeit | Laufzeit | Pro Ausführung |
| Verwaltungsaufwand | Hoch | Mittel | Minimal |
| Vendor Lock-in | Gering | Sehr gering | Mittel |
| Typischer Einsatz | Legacy, Kontrolle | Microservices | Events, APIs |

---

### Selbstreflexion Compute

**Für einen Laien erklärt:**
```
Compute in der Cloud = Rechenleistung mieten statt kaufen.
Wie Strom aus der Steckdose — du zahlst nur was du verbrauchst,
ohne ein eigenes Kraftwerk besitzen zu müssen.
```

**Entscheidungslogik:**
```
Brauche ich volle OS-Kontrolle?           → VM (EC2)
Habe ich viele kleine Services?           → Container (EKS)
Führe ich nur bei Events Code aus?        → Serverless (Lambda)
```

---

## Teil 2 — Storage im Cloud Computing

### Warum verschiedene Storage-Typen?

Verschiedene Daten haben verschiedene Anforderungen:

```
Fotos/Videos/Backups → viele Daten, selten geändert → Object Storage
Datenbank-Dateien    → niedrige Latenz, hohe IOPS   → Block Storage
Shared Config Files  → mehrere Server gleichzeitig  → File Storage
```

**Wichtige Storage-Attribute:**

| Attribut | Bedeutung |
|---|---|
| Durability | Daten gehen nicht verloren (S3: 99.999999999%) |
| Availability | Daten sind immer erreichbar (S3: 99.99%) |
| Performance | IOPS, Latenz, Durchsatz |
| Kosten | Pro GB/Monat |

---

### 3 Hauptkategorien von Storage-Services

#### 1. Object Storage

**Was ist es?**
```
→ Speichert Daten als "Objekte" (Datei + Metadaten + eindeutige ID)
→ Flache Struktur (kein klassisches Ordner-System)
→ Zugriff über HTTP/HTTPS (REST API) — von überall erreichbar
→ Theoretisch unlimitierte Skalierung
```

**Typische Daten:**
```
→ Bilder, Videos, Audio-Dateien
→ Backups und Archivierung
→ Log-Dateien
→ Static Website Files (HTML, CSS, JS)
→ Data Lake für Analytics und Machine Learning
→ Software-Downloads und Binärdateien
```

**Besonderheiten AWS S3:**
```
→ Durability: 11x9s (99.999999999%) — praktisch unzerstörbar
→ Automatische Replikation in mindestens 3 AZs
→ Versionierung möglich (ältere Versionen wiederherstellen)
→ Storage Classes: Standard, Intelligent-Tiering, Glacier (Archiv)
→ Static Website Hosting direkt aus S3 möglich
```

**Wann einsetzen?**
```
✅ Viele unstrukturierte Daten (Petabytes möglich)
✅ Daten werden selten geändert (write once, read many)
✅ Globaler Zugriff über HTTP nötig
✅ Backups und Disaster Recovery
```

**Cloud Services:** AWS S3 | Azure Blob Storage | GCP Cloud Storage

---

#### 2. Block Storage

**Was ist es?**
```
→ Speichert Daten in fixen Blöcken (wie eine physische Festplatte)
→ Wird wie eine lokale Festplatte an eine VM angehängt
→ Sehr niedrige Latenz (< 1ms), hohe IOPS
→ Kein direkter HTTP-Zugriff — nur über angehängte VM
```

**Wie funktioniert es?**
```
EBS Volume erstellen
    ↓
An EC2 Instance anhängen (wie USB-Stick einstecken)
    ↓
Formatieren (mkfs.ext4 /dev/xvdf)
    ↓
Mounten (mount /dev/xvdf /data)
    ↓
→ Verhält sich exakt wie eine lokale SSD
```

**Typische Anwendungen:**
```
→ Datenbank-Dateien (MySQL, PostgreSQL auf EC2)
→ OS-Volume einer VM (Root-Volume /dev/xvda)
→ Anwendungen mit vielen I/O-Operationen
→ Transaktionale Datenbanken die ACID brauchen
```

**Wann einsetzen?**
```
✅ Wenn sehr niedrige Latenz nötig (< 1ms)
✅ Wenn hohe IOPS nötig (Datenbanken)
✅ Wenn die VM direkten Disk-Zugriff braucht
✅ Für OS-Volumes von VMs
```

**Cloud Services:** AWS EBS | Azure Managed Disks | GCP Persistent Disk

---

#### 3. File Storage

**Was ist es?**
```
→ Netzwerk-Dateisystem (NFS/SMB Protokoll)
→ Mehrere Server können GLEICHZEITIG auf dieselben Dateien zugreifen
→ Verhält sich wie ein freigegebenes Netzlaufwerk
→ Hierarchische Ordnerstruktur (wie normales Dateisystem)
```

**Der entscheidende Unterschied zu Block Storage:**
```
Block Storage → nur EINE VM kann zugreifen (exklusiv)
File Storage  → MEHRERE VMs gleichzeitig → perfekt für Shared Data
```

**Protokolle:**
```
NFS (Network File System) → Linux-basiert → AWS EFS, GCP Filestore
SMB (Server Message Block) → Windows-basiert → Azure Files
```

**Typische Anwendungen:**
```
→ Content Management (WordPress mit mehreren Web-Servern)
→ Shared Configuration Files für Microservices
→ Home-Directories für viele Benutzer
→ Media-Verarbeitung (mehrere Server lesen/schreiben gleichzeitig)
→ Machine Learning Training (viele GPU-Instanzen lesen Trainingsdaten)
```

**Wann einsetzen?**
```
✅ Mehrere Server brauchen gleichzeitig dieselben Dateien
✅ Klassische Dateisystem-Struktur nötig (Ordner, Unterordner)
✅ Shared Storage für Auto Scaling Groups
✅ Lift & Shift von NFS-basierten Anwendungen
```

**Cloud Services:** AWS EFS | Azure Files | GCP Filestore

---

### Vergleichstabelle: Object vs Block vs File Storage

| Aspekt | Object Storage | Block Storage | File Storage |
|---|---|---|---|
| Zugriff | HTTP/HTTPS API | Direkt (wie Festplatte) | NFS/SMB Protokoll |
| Gleichzeitige Zugriffe | Millionen Clients | 1 VM (meist) | Mehrere VMs |
| Latenz | Mittel (ms) | Sehr niedrig (< 1ms) | Niedrig (ms) |
| Skalierung | Unlimitiert (PB) | Begrenzt (bis 64TB) | Groß (PB) |
| Struktur | Flach (kein Ordner) | Keine | Hierarchisch |
| Änderbarkeit | Objekt ersetzen | Byte-level schreiben | Datei bearbeiten |
| Typischer Einsatz | Backups, Media, Logs | Datenbanken, OS | Shared Files |
| AWS Service | S3 | EBS | EFS |
| Azure Service | Blob Storage | Managed Disks | Azure Files |
| GCP Service | Cloud Storage | Persistent Disk | Filestore |
| Kosten | Günstigst | Teurer | Mittel |

---

### Entscheidungslogik: Welcher Storage-Typ?

```
Frage 1: Brauchen mehrere Server gleichzeitig Zugriff?
    → Ja  → File Storage (EFS)
    → Nein → weiter zu Frage 2

Frage 2: Brauche ich sehr niedrige Latenz / hohe IOPS?
    → Ja  → Block Storage (EBS) — z.B. für Datenbanken
    → Nein → weiter zu Frage 3

Frage 3: Sind es viele unstrukturierte Daten / Backups / Media?
    → Ja  → Object Storage (S3) — günstig und skalierbar
```

---

## Selbstreflexion

**Compute — wichtigste Erkenntnis:**
Serverless ist nicht "keine Server" — es sind Server, aber AWS verwaltet sie komplett. Man zahlt nur die Millisekunden der tatsächlichen Ausführung. Für sporadische Workloads ist das revolutionär günstig.

**Storage — wichtigste Erkenntnis:**
Die Wahl des falschen Storage-Typs kann drastische Performance-Probleme verursachen. Eine Datenbank auf Object Storage zu legen wäre ein kritischer Fehler — die Latenz wäre zu hoch. Genau wie eine Datenbank-Architektur-Entscheidung.

**Verbindung zu vorherigen Themen:**
```
Compute → EC2 (VM) steht in einem VPC Subnet → Security Groups schützen es
Storage → EBS Volume an EC2 → IAM Policy kontrolliert wer darauf zugreifen darf
         → S3 Bucket Policy → Shared Responsibility: AWS sichert S3, du konfigurierst Rechte
```
