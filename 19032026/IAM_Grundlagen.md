# Aufgabe: IAM Grundlagen — Identity, Authentication & Authorization
**Datum:** 19.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Task 1 — Identity, Authentication & Authorization

### 1.1 Definitionen

| Konzept | Frage | Definition |
|---|---|---|
| **Identity** | Wer bin ich? | Die digitale Identität eines Benutzers, Systems oder Prozesses |
| **Authentication** | Beweise wer du bist! | Überprüfung der Identität durch Nachweis |
| **Authorization** | Was darfst du tun? | Festlegung der erlaubten Aktionen nach erfolgreicher Authentifizierung |

**Die Kette — immer in dieser Reihenfolge:**
```
Identity → Authentication → Authorization
"Ich bin X" → "Beweise es" → "Du darfst Y tun"
```

---

### 1.2 Praktische Beispiele

#### Alltag — Bankanruf:
```
Identity        → Name + Geburtsdatum + Adresse angeben
Authentication  → Telefon-PIN eingeben ODER SMS-Code bestätigen (2FA!)
Authorization   → Zugriff nur auf eigene Konten
                  → Keine Auskunft über Konten der Ehefrau (gleiche Bank!)
```

#### IT-System:
```
Identity        → E-Mail-Adresse (wer du bist)
Authentication  → Passwort eingeben (Beweis dass du es bist)
Authorization   → Normaler User → begrenzte Lese/Schreibrechte
                  Admin → volle Rechte
```

**Wichtige Erkenntnis:** MFA (Multi-Factor Authentication) kombiniert mehrere Authentifizierungsfaktoren:
```
Faktor 1 → Passwort (was du weißt)
Faktor 2 → SMS-Code (was du besitzt)
→ Selbst bei kompromittiertem Passwort kein Zugriff ohne 2. Faktor!
```

---

## Task 2 — Principle of Least Privilege (PoLP)

### 2.1 Definition und Bedeutung

**Least Privilege** bedeutet: Jeder Benutzer, jedes Programm und jeder Prozess erhält **nur die minimal notwendigen Rechte** — nicht mehr.

```
Falsch: Alle Benutzer bekommen Admin-Rechte → einfach zu verwalten aber gefährlich ❌
Richtig: Jeder bekommt nur was er wirklich braucht ✅
```

**Warum ist es so wichtig?**

| Risiko ohne PoLP | Konsequenz |
|---|---|
| Entwickler mit Root-Rechten | Versehentliches Löschen der Produktions-DB |
| Anwendung mit zu vielen Rechten | Bei Kompromittierung → Angreifer hat vollen Zugriff |
| nginx mit Root-Rechten | Sicherheitslücke in nginx → Root-Zugriff auf Server |

**Praxisbeispiel TryHackMe BruteIt:**
```
john konnte /bin/cat als root ausführen (zu viele Rechte!)
→ sudo cat /etc/shadow → Passwort-Hashes gelesen
→ Root-Passwort geknackt
→ Vollständige Kompromittierung des Systems
```

---

### 2.2 Anwendung auf Datenbankszenarien

**Szenario:** Drei Benutzergruppen benötigen Datenbankzugriff.

#### Database Administrator:
```
✅ Schemas ändern (CREATE, ALTER, DROP)
✅ Backups erstellen und verwalten
✅ Datenbankbenutzer verwalten
✅ Vollzugriff auf die Datenbank
❌ Zugriff auf Anwendungsserver
❌ Zugriff auf Quellcode
```

#### Application Developer:
```
✅ Daten lesen und schreiben (SELECT, INSERT, UPDATE)
✅ Zugriff auf Entwicklungs- und Testumgebung
❌ Schemas in Produktion ändern
❌ Tabellen löschen (DROP)
❌ Direktzugriff auf Produktionsdatenbank
```

#### Reporting Analyst:
```
✅ Daten nur lesen (SELECT)
✅ Berichte erstellen
❌ Daten ändern (INSERT, UPDATE, DELETE)
❌ Zugriff auf DB-Struktur oder Schemas
❌ Zugriff auf Anwendungscode
```

**In AWS mit IAM Roles umgesetzt:**
```
DBA      → IAM Role: RDS Full Access
Developer → IAM Role: RDS Read/Write
Analyst   → IAM Role: RDS Read-Only
```

→ Das ist **RBAC + Least Privilege** in der Praxis!

---

## Task 3 — IAM Tools und Best Practices

### 3.1 Gängige IAM Tools

#### AWS IAM (Amazon Web Services):
```
Anbieter    : Amazon
Funktionen  : Benutzer, Gruppen, Rollen und Policies verwalten
              MFA, Access Keys, temporäre Credentials (STS)
              JSON-basierte Policies für granulare Zugriffssteuerung
Geeignet für: Alle Unternehmen die AWS nutzen
Modell      : RBAC + Least Privilege nativ integriert
```

#### Azure Active Directory (Microsoft):
```
Anbieter    : Microsoft
Funktionen  : Identitätsverwaltung für Office 365 und Azure
              Single Sign-On (SSO) → ein Login für alle Apps
              Conditional Access → Zugriff nach Bedingungen
              (Standort, Gerät, Uhrzeit...)
Geeignet für: Unternehmen im Microsoft-Ökosystem
Modell      : RBAC
```

#### Okta:
```
Anbieter    : Okta Inc.
Funktionen  : Cloud-unabhängiges IAM (Multi-Cloud)
              SSO für tausende Anwendungen
              Universelles MFA
              Lifecycle Management (Onboarding/Offboarding)
Geeignet für: Unternehmen mit mehreren Clouds und Anwendungen
Vorteil     : Funktioniert mit AWS + Azure + Google Cloud gleichzeitig
```

---

### 3.2 IAM Best Practices

#### 1. Principle of Least Privilege
```
Warum: Minimiert den Schaden bei Kompromittierung
Wie  : IAM Policies mit minimalen Rechten definieren
       Regelmäßige Überprüfung ob Rechte noch notwendig sind
```

#### 2. MFA (Multi-Factor Authentication)
```
Warum: Selbst bei gestohlenem Passwort kein Zugriff möglich
Wie  : MFA auf ALLEN Konten aktivieren
       AWS: MFA auf Root-Account zwingend erforderlich!
Faktoren:
  - Etwas das du weißt    → Passwort
  - Etwas das du besitzt  → Smartphone/Token
  - Etwas das du bist     → Fingerabdruck/Face ID
```

#### 3. Rotation der Credentials
```
Warum: Begrenzt die Angriffsfläche bei unbekannter Kompromittierung
Wie  : Passwörter regelmäßig ändern
       AWS Access Keys rotieren
       Temporäre Credentials (IAM Roles) statt permanente Keys bevorzugen
```

#### 4. Separation of Duties
```
Warum: Verhindert Fehler und Missbrauch durch einzelne Personen
Wie  : Wer Code deployt ≠ wer es genehmigt
       DB Admin ≠ Developer ≠ Reporting Analyst
       Kritische Aktionen brauchen mehrere Genehmigungen
```

#### 5. Audit und Monitoring
```
Warum: Wer hat wann was gemacht? Verdächtiges Verhalten erkennen
Wie  : AWS CloudTrail → alle API-Aufrufe loggen
       AWS CloudWatch → Alerts bei ungewöhnlichen Aktivitäten
       Regelmäßige Überprüfung der Logs
```

---

### CIA-Triade und Best Practices

Die Best Practices sind die **konkrete Umsetzung** der CIA-Triade:

```
CIA (Theorie)         Best Practices (Umsetzung)
──────────────────────────────────────────────────
Confidentiality  →    Least Privilege + MFA
                      (nur Berechtigte können auf Daten zugreifen)

Integrity        →    Separation of Duties + Audit
                      (niemand kann unkontrolliert Änderungen vornehmen)

Availability     →    Credential Rotation + Monitoring
                      (System bleibt verfügbar und funktionsfähig)
```

---

## Selbstreflexion

**Größte Erkenntnis:**
IAM ist nicht nur Technik — es ist eine Kombination aus Prinzipien (CIA, PoLP), Modellen (RBAC, DAC, MAC) und konkreten Tools (AWS IAM, Okta, Azure AD). Alle greifen ineinander.

**Verbindung zur Praxis:**
- TryHackMe BruteIt → john mit zu vielen sudo-Rechten → Verletzung von Least Privilege
- AWS IAM Roles → RBAC + Least Privilege in der Cloud
- MFA → zweiter Faktor verhindert Brute-Force-Angriffe (wie mit Hydra)
