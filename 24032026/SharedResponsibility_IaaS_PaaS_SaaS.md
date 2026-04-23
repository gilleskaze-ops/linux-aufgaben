# Aufgabe: Shared Responsibility Model & Cloud Service-Modelle
**Datum:** 24.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — Shared Responsibility Model

### Konzept

Das Shared Responsibility Model definiert **wer für was verantwortlich ist** zwischen Cloud-Anbieter und Kunde.

**Kernformel:**
```
AWS ist verantwortlich für die Sicherheit DER Cloud
Du bist verantwortlich für die Sicherheit IN der Cloud
```

**Analogie — Wohnungsvermietung:**
```
Vermieter (AWS) → Gebäudestruktur, Dach, Heizung, Strom
Mieter (Du)     → Schlösser an deiner Tür, was du drin machst,
                  wer deinen Schlüssel bekommt
```

**Verschiebung der Verantwortung je nach Service-Modell:**
```
IaaS (EC2)     → du verwaltest OS, Apps, Daten → viel Eigenverantwortung
PaaS (RDS)     → AWS verwaltet OS, DB-Engine   → du nur Daten + App
SaaS (WorkMail)→ AWS verwaltet alles           → du nur Inhalte
```

---

### Verantwortlichkeiten im Detail

#### Sicherheit

| Aspekt | AWS | Kunde |
|---|---|---|
| Physische Sicherheit der Rechenzentren | ✅ | |
| Hypervisor-Sicherheit | ✅ | |
| Netzwerk-Infrastruktur | ✅ | |
| OS-Patches auf EC2-Instanzen | | ✅ |
| Security Groups konfigurieren | | ✅ |
| IAM Policies korrekt setzen | | ✅ |
| Daten verschlüsseln (S3, RDS...) | | ✅ |
| MFA auf allen Accounts aktivieren | | ✅ |

#### Compliance

| Aspekt | AWS | Kunde |
|---|---|---|
| ISO 27001, SOC2 Zertifizierung der Infrastruktur | ✅ | |
| DSGVO-konformes Handling der Kundendaten | | ✅ |
| Richtige Region wählen (EU-Daten in EU bleiben) | | ✅ |
| Audit-Logs aktivieren (AWS CloudTrail) | | ✅ |

#### Betrieb

| Aspekt | AWS | Kunde |
|---|---|---|
| Hardware-Wartung, Stromversorgung, Kühlung | ✅ | |
| Globale Netzwerk-Infrastruktur | ✅ | |
| OS-Updates auf verwalteten Services (RDS, Lambda) | ✅ | |
| Anwendungs-Deployments und Updates | | ✅ |
| Backups konfigurieren und testen | | ✅ |
| Monitoring einrichten (CloudWatch) | | ✅ |

---

### Größte Herausforderungen in der Praxis

```
Häufiges Missverständnis:
"AWS ist für alles verantwortlich" → FALSCH ❌

Reale Konsequenzen:
→ Datenleck wegen falsch konfiguriertem S3-Bucket → Schuld des Kunden
→ Schwache IAM-Policies → Schuld des Kunden
→ Kein MFA auf Root-Account → Schuld des Kunden
→ Unverschlüsselte Daten in S3 → Schuld des Kunden

Lösung:
→ Shared Responsibility Model von Anfang an verstehen
→ AWS Well-Architected Framework befolgen
→ Regelmäßige Security Audits durchführen
```

---

## Aufgabe 2 — IaaS (Infrastructure as a Service)

### Definition und Kernmerkmale

IaaS = Der Cloud-Anbieter stellt **rohe Infrastruktur** bereit — du verwaltest alles darüber.

**3 charakteristische Eigenschaften:**

```
1. Maximale Kontrolle
   → Du wählst OS, Middleware, Konfiguration frei
   → Volle Flexibilität wie auf eigenem Server
   → Beispiel: EC2 → Ubuntu oder Windows → du entscheidest

2. Pay-per-use
   → Nur zahlen was man wirklich nutzt
   → EC2 stoppen → Bezahlung stoppt
   → Kein fixer Kaufpreis für Hardware

3. Selbstverwaltung
   → Du bist für OS-Updates, Sicherheit, Backups zuständig
   → Mehr Arbeit aber maximale Kontrolle
   → Erfordert technisches Know-how
```

**Beispiele:** AWS EC2, AWS S3, Azure Virtual Machines, Google Compute Engine

### 3 Anwendungsfälle

**1. Web-Applikation mit spezifischer Konfiguration:**
```
→ Eigene Server-Konfiguration nötig (spezielles OS, Libraries)
→ Volle Kontrolle über Performance und Skalierung
→ IaaS perfekt weil: flexible Konfiguration, pay-per-use
```

**2. Big Data / Machine Learning Training:**
```
→ Sehr leistungsstarke GPU-Instanzen auf Abruf (p3, p4 Instanzen)
→ Nur während Training bezahlen → dann stoppen
→ IaaS perfekt weil: spezielle Hardware on-demand ohne Kauf
```

**3. Disaster Recovery:**
```
→ Backup-Infrastruktur in der Cloud bereithalten
→ Nur aktivieren wenn Hauptsystem ausfällt
→ IaaS perfekt weil: man zahlt nur im Notfall (warm standby)
```

### Start-up Entscheidung IaaS ja/nein?

```
IaaS WÄHLEN wenn:
✅ Spezifische OS/Konfiguration nötig
✅ Volle Kontrolle über Infrastruktur erforderlich
✅ Technisches DevOps-Team vorhanden

IaaS NICHT WÄHLEN wenn:
❌ Kleines Team ohne DevOps-Erfahrung
❌ Schnell deployen ohne Infrastruktur verwalten
❌ → Dann lieber PaaS (Elastic Beanstalk, Heroku)
```

---

## Aufgabe 3 — PaaS (Platform as a Service)

### Definition und Kernmerkmale

PaaS = Der Anbieter verwaltet **Infrastruktur + OS + Runtime** — du fokussierst dich nur auf deinen Code und deine Daten.

**Abstraktion im Vergleich zu IaaS:**
```
                    IaaS        PaaS
Anwendung          [Du]        [Du]
Daten              [Du]        [Du]
Runtime            [Du]        [AWS]
Middleware         [Du]        [AWS]
Betriebssystem     [Du]        [AWS]
Infrastruktur      [AWS]       [AWS]
```

**Beispiele:** AWS Elastic Beanstalk, AWS RDS, Google App Engine, Heroku, Azure App Service

### Vorteile und Limitationen

**Vorteile:**
```
✅ Schnelleres Deployment
   → Code pushen → automatisch deployen und skalieren
   → Kein OS-Management, kein Server-Setup nötig
   → Entwickler konzentrieren sich auf Code

✅ Automatische Skalierung
   → PaaS skaliert automatisch nach Bedarf
   → Kein manuelles Auto Scaling konfigurieren
   → Weniger Betriebsaufwand
```

**Nachteile:**
```
❌ Weniger Kontrolle
   → OS nicht anpassbar
   → Bestimmte Libraries/Versionen nicht immer verfügbar
   → Einschränkungen bei spezifischen Anforderungen

❌ Vendor Lock-in
   → Code auf Heroku → schwer zu AWS migrieren
   → Abhängig vom Anbieter-Ökosystem und dessen Preisen
```

### Beste Anwendungsfälle

```
✅ Gut geeignet für:
→ Entwickler-Teams ohne dediziertes DevOps-Team
→ Schnelle Prototypen und MVPs
→ Standard Web-Apps (Django, Node.js, Ruby on Rails)
→ Startups die schnell auf den Markt wollen

❌ Weniger geeignet für:
→ Apps mit speziellen OS-Anforderungen
→ Hochperformante Systeme mit Custom-Konfiguration
→ Wenn volle Infrastruktur-Kontrolle nötig ist
```

---

## Aufgabe 4 — SaaS (Software as a Service)

### Definition und Kernmerkmale

SaaS = **Fertige Software** über Internet — kein Install, kein Update, kein eigener Server.

**Vergleich On-Premise vs. SaaS:**

| Aspekt | On-Premise | SaaS |
|---|---|---|
| Installation | Manuell auf jedem Gerät | Browser → sofort nutzen |
| Updates | Manuell, oft mit Ausfallzeit | Automatisch vom Anbieter |
| Zugriff | Nur lokal/VPN | Von überall weltweit |
| Kosten | Einmalige Lizenz (hoch) | Monatliches Abo (niedrig) |
| IT-Aufwand | Eigenes Team für Wartung | Anbieter übernimmt alles |
| Skalierung | Neue Lizenzen kaufen | Einfach Abo upgraden |

### 5 Alltagsbeispiele

**1. Gmail (Google)**
```
→ E-Mail-Service komplett im Browser
→ Kein eigener E-Mail-Server nötig
→ SaaS weil: Google verwaltet Server, Backups, Updates
```

**2. Microsoft Office 365**
```
→ Word, Excel, PowerPoint im Browser und App
→ Automatische Updates, von überall zugänglich
→ SaaS weil: Abo-Modell, kein lokales Installieren auf jedem PC
```

**3. Slack**
```
→ Team-Kommunikation im Browser/App
→ Keine eigene Chat-Infrastruktur nötig
→ SaaS weil: Slack verwaltet Server, Daten, Sicherheit, Updates
```

**4. Salesforce**
```
→ CRM-System für Kundenmanagement
→ Keine eigene Datenbank aufsetzen nötig
→ SaaS weil: komplette Business-Software as a Service, Abo-Modell
```

**5. GitHub**
```
→ Code-Versionierung und Team-Zusammenarbeit
→ Kein eigener Git-Server nötig
→ SaaS weil: GitHub verwaltet Infrastruktur, Backups, Verfügbarkeit
```

### Einfluss auf Unternehmen und Alltag

```
→ Kein IT-Team für Software-Wartung nötig → Kosteneinsparung
→ Von überall arbeiten → Remote Work ermöglicht!
→ Immer aktuelle Software ohne Update-Stress
→ Skalierung: 1 User oder 10.000 User → gleiche Plattform
→ Kosten: von großer Einmalinvestition → zu monatlichem Abo
→ Collaboration: mehrere Personen gleichzeitig am selben Dokument
```

---

## Gesamtvergleich der Service-Modelle

| Aspekt | IaaS | PaaS | SaaS |
|---|---|---|---|
| Kontrolle | Maximal | Mittel | Minimal |
| Verwaltungsaufwand | Hoch | Mittel | Minimal |
| Flexibilität | Maximal | Mittel | Gering |
| Technisches Know-how | Hoch nötig | Mittel | Nicht nötig |
| Typischer Nutzer | DevOps/SysAdmin | Entwickler | Endnutzer |
| AWS Beispiel | EC2 | Elastic Beanstalk | WorkMail |
| Vendor Lock-in | Gering | Mittel | Hoch |

---

## Selbstreflexion

**Shared Responsibility — wichtigste Erkenntnis:**
AWS sichert die Infrastruktur — aber falsch konfigurierte Security Groups, offene S3-Buckets oder schwache IAM-Policies sind immer die Verantwortung des Kunden. Viele Datenlecks in der Cloud passieren nicht weil AWS gehackt wurde, sondern weil Kunden ihre Verantwortung nicht wahrgenommen haben.

**IaaS vs PaaS vs SaaS — Entscheidungslogik:**
```
Brauche ich volle Kontrolle?     → IaaS (EC2)
Will ich nur Code deployen?      → PaaS (Elastic Beanstalk)
Will ich Software nur nutzen?    → SaaS (Office 365, Slack)
```
