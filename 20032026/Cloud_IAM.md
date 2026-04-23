# Aufgabe: Cloud IAM — AWS, GCP & Azure
**Datum:** 20.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — IAM in AWS

### 1.1 Benutzer, Gruppen und Rollen

#### IAM User
Eine individuelle Identität in AWS — kann sein:
- Eine **Person** (Entwickler, Admin...)
- Eine **Anwendung** die AWS via API nutzt

```
User → hat Credentials (Username/Password oder Access Keys)
     → kann sich in die AWS Console einloggen
     → kann AWS API aufrufen
```

#### IAM Group
Sammlung von Users — Policies werden der Gruppe zugewiesen, nicht jedem User einzeln.

```
Group "Developers" → enthält user1, user2, user3
→ Policy "S3 Read" an die Gruppe anhängen
→ alle Entwickler erben automatisch S3 Read ✅
```

**Vorteil:** Neuer Entwickler kommt → zur Gruppe hinzufügen → sofort korrekte Rechte!

#### IAM Role
**Kein** dauerhafter Benutzer — eine **temporäre Identität** die "angenommen" wird:

```
Role ≠ Klassifizierung eines Users

Role = temporäre Identität, angenommen von:
→ AWS Services (EC2, Lambda, ECS...)
→ Users aus anderen AWS-Konten (Cross-Account)
→ Externe Anwendungen (Federation)
```

**Wichtiges Beispiel:**
```
EC2-Instanz möchte S3 lesen
→ IAM Role "S3ReadRole" an EC2 anhängen
→ EC2 übernimmt diese Rolle automatisch
→ Keine Credentials auf der EC2 speichern nötig! ✅
→ Sicherer als Access Keys auf dem Server
```

**Hierarchie AWS IAM:**
```
Policy  → definiert die Rechte (was darf man tun)
   ↓
User    → individuelle Identität
Group   → fasst Users zusammen → erben Policies der Gruppe
Role    → temporäre Identität für Services/Anwendungen
```

---

### 1.2 Richtlinien und Berechtigungen

#### Struktur einer IAM Policy (JSON)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::mon-bucket/*",
      "Condition": {
        "IpAddress": {
          "aws:SourceIp": "192.168.1.0/24"
        }
      }
    }
  ]
}
```

**Schlüsselelemente:**

| Element | Bedeutung | Werte |
|---|---|---|
| `Effect` | Erlauben oder verweigern | `Allow` / `Deny` |
| `Action` | Welche Aktion? | `s3:GetObject`, `ec2:StartInstances`... |
| `Resource` | Auf welche Ressource? | ARN (eindeutiger AWS-Bezeichner) |
| `Condition` | Optionale Bedingungen | IP, Uhrzeit, MFA aktiviert... |
| `Principal` | Wer? (nur bei Resource-based) | User ARN, Account ID... |

#### Identity-based vs Resource-based Policies

| Typ | Angehängt an | Principal nötig? | Anwendungsfall |
|---|---|---|---|
| **Identity-based** | User/Group/Role | ❌ Nein | Definieren was ein User tun darf |
| **Resource-based** | Ressource (S3, SQS...) | ✅ Ja | Cross-Account Zugriff ermöglichen |

**Identity-based Beispiel** (an User "gilles" angehängt):
```json
{
  "Effect": "Allow",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::mon-bucket/*"
}
```

**Resource-based Beispiel** (am S3-Bucket angehängt):
```json
{
  "Effect": "Allow",
  "Principal": {"AWS": "arn:aws:iam::123456:user/gilles"},
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::mon-bucket/*"
}
```

#### Policy Evaluation Logic

```
Grundregel: Alles ist standardmäßig DENY ❌

1. Explizites Deny   → IMMER wirksam, überschreibt alles ❌❌
2. Explizites Allow  → erlaubt die Aktion ✅
3. Kein Statement    → implizites Deny ❌

Beispiel:
Policy 1: Allow S3 GetObject
Policy 2: Deny S3 GetObject
→ Ergebnis: DENY! Der Deny gewinnt immer!
```

---

## Aufgabe 2 — IAM in GCP

### 2.1 Identitäten und Dienstkonten

#### Normaler User vs Service Account

| Aspekt | User (Mensch) | Service Account (Maschine) |
|---|---|---|
| Was? | Echte Person | Anwendung/Service |
| Authentifizierung | E-Mail + Passwort | JSON-Schlüsseldatei |
| Beispiel | gilles@gmail.com | app@projekt.iam.gserviceaccount.com |
| AWS-Äquivalent | IAM User | IAM Role für EC2/Lambda |

**Anwendungsbeispiel:**
```
User           → Du loggst dich in die GCP Console ein
Service Account → Deine Python-App liest Dateien von 
                  Google Cloud Storage automatisch
                  (ohne menschliche Interaktion)
```

**Zwei Arten von Service Accounts:**

| Typ | Verwaltet von | Verwendung |
|---|---|---|
| User-managed | Du | Eigene Anwendungen |
| Google-managed | Google | Interne GCP Services (automatisch) |

---

### 2.2 Rollen und IAM-Richtlinien

#### Drei Rollenkategorien

**Primitive Roles — breit, veraltet:**
```
Owner   → alles + Zugriffsverwaltung
Editor  → alles außer Zugriffsverwaltung
Viewer  → nur lesen

→ Zu grob, geben zu viele Rechte
→ Verletzung des Least Privilege Prinzips ❌
→ In Produktion vermeiden!
```

**Predefined Roles — präzise, von Google gepflegt:**
```
roles/storage.objectViewer    → nur GCS Objekte lesen
roles/compute.instanceAdmin   → nur VMs verwalten
roles/bigquery.dataEditor     → nur BigQuery Daten bearbeiten

→ Von Google erstellt und aktualisiert
→ Empfohlen für die meisten Anwendungsfälle ✅
→ Respektieren Least Privilege
```

**Custom Roles — ultra-präzise, von dir erstellt:**
```
Du kombinierst genau die Berechtigungen die du brauchst:
→ compute.instances.start ✅
→ compute.instances.stop ✅
→ compute.instances.delete ❌ (nicht enthalten!)

→ Maximale Kontrolle
→ Mehr Wartungsaufwand
→ Für spezielle Anforderungen wenn Predefined zu breit ist
```

#### Bindings in GCP IAM

Ein **Binding** verbindet drei Elemente:
```
Wer?              + Welche Rolle?              + Worauf?
(Member)            (Role)                       (Resource)

gilles@gmail.com → roles/storage.viewer → mon-bucket
```

**GCP Policy in JSON:**
```json
{
  "bindings": [
    {
      "role": "roles/storage.objectViewer",
      "members": [
        "user:gilles@gmail.com",
        "serviceAccount:app@projekt.iam.gserviceaccount.com"
      ]
    },
    {
      "role": "roles/compute.instanceAdmin",
      "members": [
        "group:developers@company.com"
      ]
    }
  ]
}
```

#### GCP Ressourcenhierarchie und Vererbung

```
Organisation
    ↓ erbt
  Ordner (Folder)
    ↓ erbt
  Projekt (Project)
    ↓ erbt
  Ressource (GCS Bucket, VM...)
```

Rolle auf Organisationsebene → gilt automatisch für **alles** darunter!

---

## Aufgabe 3 — IAM in Azure

### 3.1 Azure Active Directory (AAD)

#### AD Traditionell vs Azure AD

| Aspekt | AD Traditionell | Azure AD |
|---|---|---|
| Standort | Lokaler Server (on-premise) | Microsoft Cloud |
| Zugriff | Nur lokales Netzwerk | Überall via Internet |
| Protokolle | LDAP, Kerberos | OAuth 2.0, SAML, OpenID Connect |
| Verwendung | PC Windows, LAN | Office 365, Azure, SaaS-Apps |
| Verwaltung | Eigenes IT-Team | Microsoft (teilweise) |

**Analogie:**
```
AD Traditionell → HR-Büro im Firmengebäude
                  nur vor Ort erreichbar

Azure AD        → Dasselbe HR-Büro aber
                  von überall auf der Welt erreichbar
```

#### Was ist ein Tenant?

Ein **Tenant** ist dein isolierter Azure AD Bereich:
```
Microsoft verwaltet tausende Tenants:
→ Tenant von company-A.com → isoliert
→ Tenant von company-B.com → isoliert
→ Tenant von dci-digital.de → isoliert

Jedes Unternehmen hat seinen eigenen Tenant
→ Keine Dateneinsicht zwischen Tenants
```

#### 3 Hauptfunktionen von Azure AD

```
1. Single Sign-On (SSO)
   → Ein Login für Office 365, Azure, Salesforce, GitHub...
   → Kein separates Passwort für jede App

2. MFA (Multi-Factor Authentication)
   → Zweiter Faktor für alle Services
   → Selbst bei gestohlenem Passwort kein Zugriff

3. Conditional Access
   → Zugriff nur unter bestimmten Bedingungen:
   "Nur wenn Gerät von Firma verwaltet wird"
   "Blockieren bei Verbindung aus unbekanntem Land"
```

---

### 3.2 Azure RBAC

#### Die 3 Schlüsselelemente einer Rollenzuweisung

**Element 1 — Security Principal (Wer?)**
```
→ User (gilles@company.com)
→ Group (gruppe-developers)
→ Service Principal (eine Anwendung)
→ Managed Identity (wie AWS IAM Role für EC2)
```

**Element 2 — Role Definition (Welche Rechte?)**
```
Built-in Roles (von Microsoft erstellt):
→ Owner       → alles + Zugriffsverwaltung
→ Contributor → alles AUSSER Zugriffsverwaltung
→ Reader      → nur lesen, nichts ändern

Custom Roles (von dir erstellt):
→ Genau die Berechtigungen die du brauchst
```

**Element 3 — Scope (Worauf?)**
```
Hierarchie von breit nach präzise:

Management Group (Organisationsebene)
    ↓ erbt
  Subscription (Abrechnungsebene)
    ↓ erbt
    Resource Group (Container für Ressourcen)
      ↓ erbt
      Resource (VM, Storage, DB...)
```

#### Vollständiges Beispiel

```
Security Principal : gilles@company.com
Role               : Contributor
Scope              : Resource Group "production-rg"

→ Gilles kann alles in "production-rg" tun
→ Aber nicht in anderen Resource Groups!
```

#### Vererbung und Überschreiben

```
Reader auf Subscription (global)
    ↓ automatisch
  Reader auf allen Resource Groups
    ↓ automatisch
    Reader auf allen Ressourcen

ABER man kann unten präzisieren:
Reader auf Subscription (global)
    +
Contributor auf Resource Group "dev-rg" (Ausnahme)
→ Gilles kann überall lesen ABER nur in "dev-rg" ändern
```

---

## Vergleich: AWS vs GCP vs Azure

| Konzept | AWS | GCP | Azure |
|---|---|---|---|
| Identität | IAM User | Google Account | Azure AD User |
| Maschinenidentität | IAM Role | Service Account | Managed Identity |
| Gruppen | IAM Group | Google Group | Azure AD Group |
| Berechtigungen | IAM Policy (JSON) | IAM Binding | Role Assignment |
| Rollen | Managed/Inline Policy | Primitive/Predefined/Custom | Built-in/Custom |
| Hierarchie | Account → Region → Resource | Org → Folder → Project → Resource | Mgmt Group → Subscription → RG → Resource |
| Deny-Logik | Explicit Deny gewinnt immer | Explicit Deny gewinnt immer | Explicit Deny gewinnt immer |

---

## Selbstreflexion

**Gemeinsamkeiten der drei Clouds:**
- Alle verwenden RBAC als Grundmodell
- Alle haben das Konzept: Wer + Welche Rolle + Worauf
- Explicit Deny gewinnt immer gegen Allow
- Alle unterstützen MFA und Least Privilege

**Unterschiede:**
- AWS → sehr granulare JSON Policies, flexibelste Kontrolle
- GCP → einfachere Bindings, klare Rollenhierarchie
- Azure → stärkste Integration mit Microsoft-Ökosystem (Office 365)

**Wichtigste Erkenntnis:**
IAM ist das Herzstück jeder Cloud-Architektur. Egal ob AWS, GCP oder Azure — die Prinzipien sind identisch: Least Privilege, RBAC, MFA, Audit. Nur die Syntax und die Namen ändern sich.
