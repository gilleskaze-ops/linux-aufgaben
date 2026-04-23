# Aufgabe: Cloud Computing Grundlagen & Globale Infrastruktur
**Datum:** 23.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — Cloud Computing Grundlagen

### 1.1 Was ist Cloud Computing?

Cloud Computing = IT-Ressourcen (Server, Speicher, Datenbanken, Software) **über das Internet on-demand bereitstellen** — statt eigene Hardware zu kaufen und zu betreiben.

**5 Charakteristika (NIST Definition):**

```
1. On-demand Self-Service
   → Ressourcen selbst provisionieren ohne menschliche Interaktion
   → Beispiel: EC2 in 2 Minuten starten ohne AWS anzurufen

2. Broad Network Access
   → Zugriff über Standard-Netzwerke (Internet) von überall
   → PC, Smartphone, Tablet...

3. Resource Pooling
   → Ressourcen werden von vielen Kunden geteilt (Multi-tenancy)
   → Deine EC2 läuft auf demselben physischen Server wie andere Kunden
   → Du siehst aber nur deine eigenen Ressourcen

4. Rapid Elasticity
   → Ressourcen schnell hoch- und runterskalieren
   → Black Friday: 10x mehr Server → danach wieder reduzieren

5. Measured Service
   → Pay-per-use: nur zahlen was man wirklich nutzt
   → Wie Strom oder Wasser — nur verbrauchte Menge bezahlen
```

---

### 1.2 On-Premises vs. Cloud

```
ON-PREMISES:
→ Eigene Server im eigenen Rechenzentrum
→ Du kaufst, installierst, wartest alles selbst
→ Hohe Anfangskosten (CapEx — Capital Expenditure)
→ Lange Beschaffungszeiten (Wochen/Monate)

CLOUD:
→ Server beim Cloud-Anbieter (AWS, Azure, GCP)
→ Anbieter kümmert sich um Hardware, Wartung, Strom
→ Laufende Kosten (OpEx — Operational Expenditure)
→ Ressourcen in Minuten verfügbar
```

**Vergleichstabelle:**

| Aspekt | On-Premises | Cloud |
|---|---|---|
| Kosten | Hohe Anfangsinvestition (CapEx) | Laufende Kosten (OpEx) |
| Skalierbarkeit | Begrenzt, langsam | Sofort, unbegrenzt |
| Wartung | Eigenes IT-Team | Anbieter übernimmt |
| Kontrolle | Vollständig | Eingeschränkt |
| Sicherheit | Du bist verantwortlich | Geteilte Verantwortung |
| Time-to-market | Wochen/Monate | Minuten |

**Wann On-Premises?**
- Sehr strenge Compliance-Anforderungen (Militär, Banken)
- Sehr sensible Daten die das Unternehmen nicht verlassen dürfen
- Sehr stabile, vorhersehbare Workloads ohne Skalierungsbedarf

**Wann Cloud?**
- Schnelles Wachstum, variable Workloads
- Globale Reichweite nötig
- Kleines IT-Team, kein eigenes Rechenzentrum möglich

---

### 1.3 Service-Modelle: IaaS, PaaS, SaaS

#### IaaS — Infrastructure as a Service
```
Du bekommst  : Server, Netzwerk, Speicher
Du verwaltest: OS, Middleware, Apps, Daten
AWS verwaltet: Hardware, Hypervisor, Rechenzentrum

Beispiele: AWS EC2, Azure Virtual Machines, Google Compute Engine
```

#### PaaS — Platform as a Service
```
Du bekommst  : Plattform zum Entwickeln und Deployen
Du verwaltest: nur deine Anwendung und Daten
AWS verwaltet: OS, Middleware, Runtime, Hardware

Beispiele: AWS Elastic Beanstalk, Google App Engine, Heroku
```

#### SaaS — Software as a Service
```
Du bekommst  : fertige Anwendung
Du verwaltest: nur deine Daten und Konfiguration
AWS verwaltet: alles andere

Beispiele: Gmail, Office 365, Salesforce, Slack
```

#### Shared Responsibility Model

```
                    IaaS      PaaS      SaaS
Anwendung          [Du]      [Du]      [AWS]
Daten              [Du]      [Du]      [Du]
Runtime            [Du]      [AWS]     [AWS]
Middleware         [Du]      [AWS]     [AWS]
Betriebssystem     [Du]      [AWS]     [AWS]
Virtualisierung    [AWS]     [AWS]     [AWS]
Hardware/Server    [AWS]     [AWS]     [AWS]
Rechenzentrum      [AWS]     [AWS]     [AWS]
```

**Pizza-Analogie:**
```
On-Premises → alles selbst machen (Zutaten kaufen, backen...)
IaaS        → Zutaten kaufen, selbst kochen (Küche gemietet)
PaaS        → Pizza zum Selbstabholen bestellen
SaaS        → Pizza-Lieferservice — du isst nur
```

---

### 1.4 Vorteile und Herausforderungen der Cloud

**Vorteile:**
```
✅ Kostenersparnis    → kein CapEx, nur OpEx (pay-per-use)
✅ Agilität           → neue Ressourcen in Minuten verfügbar
✅ Globale Reichweite → in Sekunden weltweit deployen
✅ Skalierbarkeit     → automatisch hoch/runterskalieren
✅ Innovation         → neueste Technologien sofort verfügbar
✅ Disaster Recovery  → einfache Backups, Multi-Region Deployments
```

**Herausforderungen:**
```
❌ Datensicherheit    → Daten beim Anbieter — wer hat Zugriff?
❌ Compliance         → DSGVO, HIPAA — dürfen Daten in die Cloud?
❌ Vendor Lock-in     → alles auf AWS → schwer zu wechseln
❌ Kosten             → ohne Monitoring explodierende Rechnungen
❌ Internetabhängigkeit → kein Internet = kein Zugriff
❌ Weniger Kontrolle  → kein physischer Zugriff auf Server
```

---

## Aufgabe 2 — Globale Infrastruktur

### 2.1 Was ist globale Infrastruktur?

Cloud-Anbieter betreiben **physische Rechenzentren weltweit** um:
- Niedrige Latenz für Nutzer überall zu gewährleisten
- Ausfallsicherheit durch geografische Verteilung
- Compliance-Anforderungen zu erfüllen (Daten in bestimmten Ländern)

---

### 2.2 Regionen, Availability Zones und Rechenzentren

#### Region
```
→ Geografischer Bereich mit mehreren AZs
→ Beispiele: eu-west-1 (Irland), us-east-1 (Virginia), eu-central-1 (Frankfurt)
→ Vollständig voneinander isoliert
→ Daten verlassen die Region nicht (standardmäßig)
→ Man wählt die Region die am nächsten zu den Nutzern ist
```

#### Availability Zone (AZ)
```
→ Ein oder mehrere physische Rechenzentren innerhalb einer Region
→ Verbunden durch schnelle private Netzwerke (< 1ms Latenz)
→ Getrennte Stromversorgung, Kühlung, Netzwerk → unabhängige Ausfälle
→ Beispiele: eu-west-1a, eu-west-1b, eu-west-1c
```

#### Rechenzentrum
```
→ Physisches Gebäude mit Tausenden von Servern
→ Gehört zu einer AZ
→ Redundante Stromversorgung, Kühlung, physische Sicherheit
```

#### Hierarchie
```
Region (eu-west-1 — Irland)
    ├── AZ eu-west-1a
    │       ├── Rechenzentrum 1
    │       └── Rechenzentrum 2
    ├── AZ eu-west-1b
    │       └── Rechenzentrum 3
    └── AZ eu-west-1c
            └── Rechenzentrum 4
```

#### Warum mehrere AZs pro Region?
```
→ Wenn AZ-1a ausfällt (Brand, Stromausfall, Überschwemmung...)
→ AZ-1b und AZ-1c laufen weiter
→ Deine Anwendung bleibt verfügbar!
→ Das nennt man High Availability (HA)
```

---

### 2.3 Redundanz und Skalierbarkeit

#### Redundanz
```
→ Jede Komponente mehrfach vorhanden → kein Single Point of Failure (SPOF)

Techniken:
- Multi-AZ Deployments → Datenbank läuft in 2 AZs gleichzeitig
- Load Balancer        → verteilt Traffic auf mehrere Server
- Auto Scaling         → ersetzt ausgefallene Instanzen automatisch
- S3 Replikation       → Daten in mind. 3 AZs gespeichert (11x9s Durability!)
```

#### Skalierbarkeit
```
Horizontal (Scale Out) → mehr Server hinzufügen
Vertikal (Scale Up)    → größerer Server (mehr RAM/CPU)

Auto Scaling in AWS:
→ Auto Scaling Groups → EC2s automatisch hinzufügen/entfernen
→ Basierend auf CPU-Auslastung, Netzwerk, Custom Metrics
→ Black Friday: 100 Server → danach wieder 5 → nur Verbrauchtes bezahlen
```

---

### 2.4 Performance und Zuverlässigkeit

#### Performance / Latenz
```
Nutzer in Tokyo     → Region ap-northeast-1 (Tokyo) → niedrige Latenz ✅
Nutzer in Frankfurt → Region eu-central-1 (Frankfurt) → niedrige Latenz ✅

CDN (CloudFront in AWS):
→ Inhalte an Edge Locations gecacht (400+ weltweit)
→ Video in Australien? → kommt von Sydney Edge, nicht aus Virginia!
→ Drastisch reduzierte Latenz für statische Inhalte
```

#### Zuverlässigkeit / SLA
```
AWS S3           → 99.999999999% Durability (11x9s)
AWS EC2 Multi-AZ → 99.99% Availability SLA
AWS RDS Multi-AZ → automatisches Failover in < 60 Sekunden

Wenn eine AZ ausfällt:
→ Load Balancer erkennt den Ausfall
→ Traffic wird automatisch auf andere AZs umgeleitet
→ Nutzer merken (fast) nichts → das ist echte Hochverfügbarkeit
```

---

## Vergleich der drei Cloud-Anbieter

| Aspekt | AWS | Azure | GCP |
|---|---|---|---|
| Regionen | 33 Regionen | 60+ Regionen | 35+ Regionen |
| Marktführer | ✅ Nr. 1 | Nr. 2 | Nr. 3 |
| Stärke | Breite Services | Microsoft-Integration | KI/ML, Big Data |
| Zertifizierung | AWS SAA | AZ-900/AZ-201 | GCP ACE |

---

## Selbstreflexion

**Wichtigste Erkenntnisse:**
- Cloud ist nicht nur "Server im Internet" — es ist ein komplettes Betriebsmodell mit klaren Verantwortlichkeiten (Shared Responsibility)
- Die Wahl zwischen IaaS/PaaS/SaaS bestimmt wie viel Kontrolle und wie viel Verwaltungsaufwand man hat
- Multi-AZ Deployments sind der Schlüssel zu echter Hochverfügbarkeit

**Verbindung zu vorherigen Themen:**
- Subnetting → VPC Subnets in verschiedenen AZs
- IAM → gilt für alle Regionen des AWS-Kontos
- Firewalls → Security Groups in jeder AZ/VPC
- SSH → Zugriff auf EC2 Instanzen in beliebigen Regionen
