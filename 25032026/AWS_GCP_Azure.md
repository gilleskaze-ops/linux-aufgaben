# Aufgabe: Cloud-Anbieter — AWS, GCP & Azure
**Datum:** 25.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## AWS — Amazon Web Services

### Überblick

AWS ist der **Marktführer** im Cloud Computing (seit 2006) mit über 200 Services. Gestartet als interne Infrastruktur von Amazon, heute genutzt von Startups bis Fortune 500 Unternehmen.

```
Gegründet  : 2006
Marktanteil: ~32% (Nr. 1 weltweit)
Regionen   : 33 Regionen, 105 Availability Zones
Vision     : Jede Unternehmens-IT in die Cloud — "any workload, anywhere"
```

**Attraktiv für:** Startups, Tech-Unternehmen, Enterprises, Government, alle Branchen

---

### 5 Schlüssel-Services

#### 1. EC2 — Elastic Compute Cloud (IaaS)
```
Was      : Virtuelle Server in der Cloud
Kontrolle: Du verwaltest OS, Apps, Konfiguration
Typen    : Hunderte von Instanztypen (t3.micro → p4d.24xlarge)

Anwendungsfälle:
→ Web-Server und API-Backends
→ Machine Learning Training (GPU-Instanzen)
→ Gaming-Server, HPC (High Performance Computing)
```

#### 2. S3 — Simple Storage Service (Object Storage)
```
Was      : Unbegrenzter Datei-Speicher im Internet
Durability: 99.999999999% (11x9s) — praktisch unzerstörbar
Zugriff  : Weltweit über HTTPS erreichbar

Anwendungsfälle:
→ Backups und Disaster Recovery
→ Static Website Hosting
→ Data Lake für Analytics und ML
→ Media-Speicherung (Bilder, Videos)
```

#### 3. Lambda — Serverless Computing
```
Was      : Code ausführen ohne Server zu verwalten
Bezahlung: Nur pro Ausführung (pro Millisekunde)
Trigger  : HTTP, S3-Events, DynamoDB Streams, CloudWatch...

Anwendungsfälle:
→ API Backends (REST APIs)
→ Event-driven Processing
→ Automatische Bildkomprimierung bei S3-Upload
→ Scheduled Tasks (wie Cron-Jobs in der Cloud)
```

#### 4. RDS — Relational Database Service (PaaS)
```
Was      : Verwaltete relationale Datenbanken
Engines  : MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, Aurora
AWS übernimmt: Backups, Patches, Multi-AZ Failover

Anwendungsfälle:
→ Produktions-Datenbank für Web-Anwendungen
→ Migration von on-premise Datenbanken
→ Multi-AZ für Hochverfügbarkeit
```

#### 5. VPC — Virtual Private Cloud (Networking)
```
Was      : Eigenes isoliertes Netzwerk in AWS
Enthält  : Subnets, Security Groups, Route Tables, Internet Gateway
Basis    : Jede AWS-Architektur baut auf einem VPC auf

Anwendungsfälle:
→ Öffentliche und private Netzwerke trennen
→ Sichere Verbindung zu on-premise (VPN/Direct Connect)
→ Isolation verschiedener Umgebungen (Dev, Staging, Prod)
```

---

### Alleinstellungsmerkmale AWS

```
✅ Größtes Service-Portfolio (200+ Services)
✅ Größte globale Infrastruktur (33 Regionen, 105 AZs)
✅ Reifste Plattform (seit 2006 — größte Erfahrung)
✅ Größtes Partner-Ökosystem und Community
✅ Granulare Pay-per-use Abrechnung
✅ Beste Dokumentation und Lernressourcen
```

---

## GCP — Google Cloud Platform

### Überblick

GCP ist der **drittgrößte** Cloud-Anbieter. Googles eigene Infrastruktur — dieselbe die Gmail, YouTube und Google Search betreibt — jetzt für alle Unternehmen verfügbar.

```
Gegründet  : 2008
Marktanteil: ~11% (Nr. 3 weltweit)
Stärken    : KI/ML, Big Data, Kubernetes, globales Netzwerk
Besonderheit: Google hat Kubernetes erfunden!
```

**Attraktiv für:** Data Scientists, KI-Unternehmen, Tech-Startups, Unternehmen mit Big Data Bedarf

---

### 5 Schlüssel-Services

#### 1. Compute Engine (IaaS) — entspricht AWS EC2
```
Was      : Virtuelle Maschinen in Googles Infrastruktur
Vorteil  : Sustained Use Discounts — Preise sinken automatisch
           bei langer Nutzung (kein manuelles Reserved Instance)

Anwendungsfälle:
→ Web-Server, Batch-Processing
→ Migration von on-premise Workloads
```

#### 2. Cloud Storage (Object Storage) — entspricht AWS S3
```
Was      : Globaler Objekt-Speicher
Klassen  : Standard, Nearline, Coldline, Archive

Anwendungsfälle:
→ Backups, Media-Hosting
→ Data Lake für BigQuery Analytics
```

#### 3. BigQuery — Data Warehouse (Googles Killer-Feature)
```
Was      : Serverless SQL-Analyse auf Petabyte-Scale
Besonders: Kein Infrastruktur-Management — nur SQL schreiben
Geschw.  : Milliarden Zeilen in Sekunden abfragen

Anwendungsfälle:
→ Business Intelligence und Reporting
→ Log-Analyse (Milliarden Events täglich)
→ Marketing-Analytics, Customer Insights
→ Googles größtes Alleinstellungsmerkmal im Data-Bereich
```

#### 4. GKE — Google Kubernetes Engine
```
Was      : Verwalteter Kubernetes-Cluster
Vorteil  : Google hat Kubernetes erfunden → beste Integration
           Autopilot-Modus → keine Node-Verwaltung nötig

Anwendungsfälle:
→ Container-Deployments und Microservices
→ Multi-Cloud Kubernetes (mit Anthos)
```

#### 5. Cloud Functions — Serverless — entspricht AWS Lambda
```
Was      : Code ohne Server ausführen
Trigger  : HTTP, Cloud Pub/Sub, Cloud Storage, Firestore

Anwendungsfälle:
→ API Backends, Event-driven Processing
→ Datenverarbeitung bei File-Uploads
```

---

### Alleinstellungsmerkmale GCP

```
✅ Beste KI/ML Services weltweit (Vertex AI, TensorFlow, TPUs)
✅ BigQuery — ungeschlagen für Data Analytics
✅ Kubernetes — GCP hat es erfunden, beste native Integration
✅ Googles privates globales Glasfasernetzwerk (schnellste Latenz)
✅ Günstigste Preise bei Compute (automatische Sustained Use Discounts)
✅ Carbon-neutral seit 2007, 100% erneuerbare Energie
```

---

## Azure — Microsoft Cloud

### Überblick

Azure ist der **zweitgrößte** Cloud-Anbieter. Microsofts strategische Antwort auf AWS — tief integriert in das gesamte Microsoft-Ökosystem.

```
Gegründet  : 2010
Marktanteil: ~22% (Nr. 2 weltweit)
Stärken    : Microsoft-Integration, Hybrid Cloud, Enterprise, Compliance
```

**Brücken zur Microsoft-Welt:**
```
Windows Server on-premise → Azure VMs (einfache Migration)
Active Directory lokal     → Azure Active Directory (Cloud)
SQL Server on-premise      → Azure SQL Database (Cloud)
.NET Anwendungen           → Azure App Service
Office 365 / Teams         → Azure AD als Identity Provider
Visual Studio              → Azure DevOps Integration
```

**Attraktiv für:** Unternehmen mit Microsoft-Infrastruktur, Enterprises, .NET-Entwickler, Banken und Regierungen (Compliance)

---

### 5 Schlüssel-Services

#### 1. Azure Virtual Machines — IaaS (= AWS EC2)
```
Was      : Virtuelle Server in Microsofts Cloud
Vorteil  : Unterstützt Windows und Linux
           Azure Hybrid Benefit → günstige Windows-Lizenzen

Anwendungsfälle:
→ Migration von on-premise Windows-Servern (Lift & Shift)
→ Legacy-Anwendungen in die Cloud heben
→ Windows-spezifische Workloads
```

#### 2. Azure Blob Storage — Object Storage (= AWS S3)
```
Was      : Massenhafte unstrukturierte Datenspeicherung
Tiers    : Hot, Cool, Cold, Archive

Anwendungsfälle:
→ Backups und Disaster Recovery
→ Media-Dateien und Log-Archivierung
→ Data Lake für Azure Analytics
```

#### 3. Azure Functions — Serverless (= AWS Lambda)
```
Was      : Code ohne Server ausführen
Trigger  : HTTP, Timer, Service Bus, Blob Storage...

Anwendungsfälle:
→ API Backends für .NET Anwendungen
→ Timer-Jobs und geplante Aufgaben
→ Event-driven Processing
```

#### 4. Azure SQL Database — PaaS (= AWS RDS)
```
Was      : Verwalteter SQL Server in der Cloud
Microsoft übernimmt: Patches, Backups, Hochverfügbarkeit
Vorteil  : Beste Integration für bestehende SQL Server Apps

Anwendungsfälle:
→ Produktions-DB für .NET Anwendungen
→ Migration von on-premise SQL Server
→ Hochverfügbare Unternehmens-Datenbanken
```

#### 5. Azure Active Directory — Identity (= AWS IAM + mehr)
```
Was      : Cloud-Identity Provider für Microsoft-Ökosystem
Funktionen: SSO, MFA, Conditional Access, B2B/B2C

Anwendungsfälle:
→ Unternehmens-Identitätsmanagement
→ SSO für Office 365, Teams, Azure, SaaS-Apps
→ Remote Work (sicherer Login von überall)
→ Zugriff für externe Partner (B2B Federation)
```

---

### Alleinstellungsmerkmale Azure

```
✅ Beste Integration mit Microsoft-Ökosystem
   (Windows, Office 365, Teams, GitHub, LinkedIn)
✅ Stärkste Hybrid-Cloud Lösung (Azure Arc)
   → On-premise + Cloud nahtlos verbinden
✅ Größtes Compliance-Portfolio (90+ Zertifizierungen)
   → Wichtig für Banken, Regierungen, Gesundheitswesen
✅ Azure AD — Identity-Leader im Enterprise-Bereich
✅ Günstigste Windows-Lizenzen (Azure Hybrid Benefit)
✅ Stärkste .NET und Visual Studio Integration
```

---

## Gesamtvergleich: AWS vs GCP vs Azure

| Aspekt | AWS | GCP | Azure |
|---|---|---|---|
| Marktposition | Nr. 1 (~32%) | Nr. 3 (~11%) | Nr. 2 (~22%) |
| Gegründet | 2006 | 2008 | 2010 |
| Stärke | Breite, Reife | KI/ML, Big Data | Microsoft-Integration |
| Compute | EC2 | Compute Engine | Virtual Machines |
| Object Storage | S3 | Cloud Storage | Blob Storage |
| Serverless | Lambda | Cloud Functions | Azure Functions |
| Managed DB | RDS | Cloud SQL | Azure SQL Database |
| Kubernetes | EKS | GKE (Erfinder!) | AKS |
| Identity | IAM | Cloud IAM | Azure AD |
| Regionen | 33 | 35+ | 60+ |
| Zielgruppe | Alle Branchen | Tech/Data/KI | Microsoft-Kunden |

---

## Selbstreflexion

**Gemeinsamkeiten der drei Anbieter:**
- Alle bieten IaaS, PaaS und SaaS an
- Alle haben globale Infrastruktur mit Regionen und AZs
- Alle folgen dem Shared Responsibility Model
- Alle unterstützen Kubernetes, Serverless und Managed Databases

**Wichtigste Unterschiede:**
```
AWS   → Marktführer, größtes Portfolio, beste für neue Cloud-Projekte
GCP   → Beste KI/ML und Big Data, günstigste Compute-Preise
Azure → Beste für Unternehmen mit Microsoft-Infrastruktur
```

**Für die DCI-Zertifizierungen:**
```
AWS SAA → Schwerpunkt dieser Weiterbildung
AZ-201  → Azure (optional)
→ AWS-Kenntnisse lassen sich gut auf Azure/GCP übertragen
  da die Konzepte identisch sind — nur die Namen ändern sich
```
