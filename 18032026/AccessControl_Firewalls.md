# Aufgabe: Access Control & Firewalls
**Datum:** 18.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Teil 1 — Access Control

### Aufgabe 1: Authentifizierung vs. Autorisierung

#### Definitionen

**Authentifizierung (Authentication):** Überprüfung der Identität — *"Wer bist du?"*

**Autorisierung (Authorization):** Festlegung der Zugriffsrechte — *"Was darfst du?"*

---

#### Zusammenspiel und Beispiele

| Szenario | Authentifizierung | Autorisierung |
|---|---|---|
| Nachtclub | Personalausweis prüfen → Wer bist du? | Volljährig? → Du darfst rein |
| Postamt | Personalausweis zeigen → Wer bist du? | Dein Paket → Du darfst es abholen |
| Supermarkt | Mitarbeiterausweis → Wer bist du? | Mitarbeiter → Du darfst in den Lagerraum |
| Website | Username + Passwort / SSH-Key | Admin → User erstellen / User → nur lesen |

**Technisches Beispiel AWS:**
```
Authentifizierung : IAM-Benutzer mit MFA anmelden
Autorisierung     : IAM-Policy definiert was der Benutzer darf
                    (z.B. S3 lesen aber nicht schreiben)
```

---

#### Warum ist die korrekte Implementierung unerlässlich?

**Wenn Authentifizierung schlecht konfiguriert:**
- Jeder kann sich als jemand anderes ausgeben
- Schwache Passwörter → Brute-Force-Angriffe (wie mit Hydra auf TryHackMe)

**Wenn Autorisierung schlecht konfiguriert:**
- Authentifizierte Benutzer können mehr tun als erlaubt
- Beispiel: HR-Mitarbeiter greift auf Finanzdaten zu
- Beispiel: Entwickler kann Produktionssysteme ändern

**Grundprinzip: Least Privilege**
Jeder Benutzer bekommt nur die Rechte, die er wirklich braucht — nicht mehr.

```
Falsch : Alle Benutzer bekommen root-Rechte → enormes Sicherheitsrisiko ❌
Richtig: Jeder bekommt nur die minimal notwendigen Rechte ✅
```

**In AWS kritisch:**
```
Schlechte Auth  → AWS-Konto kompromittiert → gesamte Infrastruktur gefährdet
Schlechte Authz → Lambda-Funktion mit root-Rechten → bei Kompromittierung
                  ist alles zugänglich
```

---

### Aufgabe 2: Zugriffssteuerungsmodelle (DAC, MAC, RBAC)

#### DAC — Discretionary Access Control

**Prinzip:** Der **Eigentümer** einer Ressource entscheidet, wer darauf zugreifen darf.

**Wie Zugriffsentscheidungen getroffen werden:**
Der Besitzer vergibt Rechte direkt an andere Benutzer oder Gruppen — nach eigenem Ermessen.

**Linux-Beispiel:**
```bash
chmod 600 ~/.ssh/id_rsa    # Eigentümer entscheidet über Zugriffsrechte
chmod 755 script.sh        # Lese/Ausführungsrechte für alle
chown gikaze datei.txt     # Eigentümer wechseln
```

**Typische Anwendungsbereiche:** Linux/Windows Dateisysteme, persönliche Dokumente

| Vorteil | Nachteil |
|---|---|
| Flexibel, einfach zu verwalten | Sicherheit hängt vom Eigentümer ab — Fehler möglich |

**In AWS:** S3 Bucket ACLs → Bucket-Eigentümer entscheidet über Zugriff

---

#### MAC — Mandatory Access Control

**Prinzip:** Eine **zentrale Instanz** (System/Administrator) legt die Zugriffsregeln fest — nicht der Eigentümer.

**Wie Zugriffsentscheidungen getroffen werden:**
Ressourcen werden klassifiziert (z.B. Public, Internal, Confidential, Top Secret). Benutzer haben Sicherheitsstufen. Zugriff nur wenn Stufe des Benutzers >= Stufe der Ressource.

**Beispiel Klassifizierung:**
```
TOP SECRET   → nur Generäle und Minister
VERTRAULICH  → leitende Offiziere
INTERNAL     → alle Mitarbeiter
PUBLIC       → jeder
```

Selbst der Ersteller eines Dokuments kann es nicht eigenständig deklassifizieren — das System entscheidet!

**Typische Anwendungsbereiche:** Militär, Geheimdienste, Regierungsbehörden

| Vorteil | Nachteil |
|---|---|
| Sehr hohe Sicherheit, nicht umgehbar | Sehr starr, wenig flexibel, hoher Verwaltungsaufwand |

**In AWS:** AWS Organizations SCPs (Service Control Policies) → zentrale Regeln die selbst Account-Admins nicht umgehen können

**Auf Linux:** SELinux verwendet MAC-Prinzipien

---

#### RBAC — Role-Based Access Control

**Prinzip:** Rechte werden **Rollen** zugewiesen, nicht direkt Benutzern. Benutzer erben die Rechte ihrer Rolle.

**Wie Zugriffsentscheidungen getroffen werden:**
Administrator definiert Rollen mit bestimmten Rechten. Benutzer werden Rollen zugewiesen. Bei Rollenwechsel ändern sich automatisch alle Rechte.

**AWS IAM Beispiel:**
```
Rolle "Developer":
→ S3 lesen ✅
→ Lambda deployen ✅
→ CloudWatch Logs einsehen ✅
→ RDS zugreifen ❌

Rolle "DBA":
→ RDS zugreifen ✅
→ Backups erstellen ✅
→ EC2 verwalten ❌

Rolle "Admin":
→ Alles ✅
```

Neuer Entwickler kommt → Rolle "Developer" zuweisen → sofort korrekte Rechte!

**Typische Anwendungsbereiche:** AWS IAM, Azure AD, Webanwendungen, Unternehmens-IT

| Vorteil | Nachteil |
|---|---|
| Skalierbar, einfach verwaltbar bei vielen Benutzern | Rollenkonzeption am Anfang komplex |

---

#### Vergleich der drei Modelle

| Merkmal | DAC | MAC | RBAC |
|---|---|---|---|
| Wer entscheidet? | Eigentümer | Zentrales System | Administrator via Rollen |
| Flexibilität | Hoch | Sehr niedrig | Mittel |
| Sicherheitsniveau | Mittel | Sehr hoch | Hoch |
| Verwaltungsaufwand | Niedrig | Sehr hoch | Mittel |
| Typischer Einsatz | Linux/Windows | Militär/Regierung | AWS/Azure/Apps |

---

## Teil 2 — Firewalls

### Aufgabe 3: Zweck und Notwendigkeit von Firewalls

#### Grundlegende Funktion

Eine Firewall ist der **Wächter des Netzwerks** — sie filtert ein- und ausgehenden Datenverkehr anhand definierter Regeln.

Sie kontrolliert:
- Welche **Ports** geöffnet oder gesperrt sind
- Welche **IP-Adressen** zugelassen oder blockiert werden
- Welche **Protokolle** erlaubt sind

#### Schutzziele (CIA-Triade)

| Schutzziel | Beschreibung | Firewall-Beitrag |
|---|---|---|
| **Vertraulichkeit** | Daten nur für Berechtigte zugänglich | Blockiert unbefugte Zugriffe |
| **Integrität** | Daten werden nicht unbefugt verändert | Verhindert Man-in-the-Middle-Angriffe |
| **Verfügbarkeit** | System bleibt erreichbar | Schützt vor DDoS-Angriffen |

#### Konkrete Bedrohungsszenarien

| Bedrohung | Beschreibung | Firewall-Schutz |
|---|---|---|
| Port Scanning | Angreifer sucht offene Ports (nmap) | Ports sperren / Rate limiting |
| DDoS | Flut von Paketen überlastet den Server | Traffic-Begrenzung |
| Brute Force SSH | Wiederholte Login-Versuche | IP nach X Fehlversuchen sperren (fail2ban!) |
| Malware C&C | Schadsoftware kommuniziert nach außen | Ausgehenden Traffic filtern |

---

### Aufgabe 4: Arten von Firewalls

#### Typ 1 — Paketfilter-Firewall (Packet Filter)

**Arbeitsebene:** OSI Schicht 3-4 (Network + Transport)

**Funktionsweise:**
Jedes Paket wird einzeln und unabhängig geprüft — kein Gedächtnis für vorherige Pakete (stateless).

```
Regel: Blockiere alle Pakete von IP 10.0.0.5 auf Port 22
→ Paket kommt an → prüfe IP und Port → blockieren oder durchlassen
```

**Analogie:** Ein Türsteher der nur die Jackenfarbe prüft — keine Identitätskontrolle, kein Kontext.

| Vorteil | Nachteil |
|---|---|
| Sehr schnell, wenig Ressourcen | Kein Kontext — kann legitime von gefälschten Paketen nicht unterscheiden |

**In AWS:** NACLs (Network Access Control Lists) → stateless, Regeln für Ein- UND Ausgang separat definieren

---

#### Typ 2 — Stateful Inspection Firewall

**Arbeitsebene:** OSI Schicht 3-4, aber mit Verbindungsgedächtnis

**Funktionsweise:**
Merkt sich den **Zustand aktiver Verbindungen** (Connection State Table).

```
Client → Server: SYN (Verbindungsanfrage)
Firewall merkt: "Verbindung läuft zwischen Client X und Server Y"
Server → Client: SYN-ACK
Firewall erkennt: legitime Antwort → durchlassen ✅

Fremdes Paket → SYN-ACK ohne vorheriges SYN
Firewall erkennt: keine bekannte Verbindung → blockieren ❌
```

**Analogie:** Ein Türsteher der sich merkt wer reingegangen ist — wenn jemand rauskommt weiß er dass die Person drin war.

| Vorteil | Nachteil |
|---|---|
| Versteht Verbindungskontext, sicherer als Paketfilter | Langsamer, mehr Ressourcen |

**In AWS:** Security Groups → stateful! Eingehender Traffic erlaubt → Antwort geht automatisch raus

---

#### Typ 3 — Application-Level Firewall (WAF / Proxy)

**Arbeitsebene:** OSI Schicht 7 (Application)

**Funktionsweise:**
Analysiert den **Inhalt** der Pakete auf Anwendungsebene — versteht HTTP, SQL, etc.

```
HTTP-Anfrage: GET /admin/../../../etc/passwd
→ Firewall erkennt Path Traversal Angriff → blockieren ✅

SQL-Anfrage: SELECT * FROM users WHERE id=1 OR 1=1
→ Firewall erkennt SQL-Injection → blockieren ✅
```

**Analogie:** Ein Türsteher der den Inhalt deiner Tasche durchsucht und prüft was du mitbringst.

| Vorteil | Nachteil |
|---|---|
| Erkennt komplexe Angriffe auf Anwendungsebene | Langsamer, teurer, komplexer |

**In AWS:** WAF (Web Application Firewall) → schützt vor SQL Injection, XSS, Path Traversal

---

#### Vergleich der drei Firewall-Typen

| Merkmal | Paketfilter | Stateful Inspection | Application-Level |
|---|---|---|---|
| OSI-Schicht | 3-4 | 3-4 | 7 |
| Geschwindigkeit | Sehr schnell | Schnell | Langsam |
| Sicherheitsniveau | Niedrig | Mittel | Hoch |
| Komplexität | Einfach | Mittel | Komplex |
| AWS-Entsprechung | NACLs | Security Groups | WAF |
| Stateful/Stateless | Stateless | Stateful | Stateful |

---

#### Geschichtete Sicherheit in AWS (Defense in Depth)

In der Praxis kombiniert man alle drei Typen:

```
Internet
    ↓
WAF (Application-Level) → SQL Injection, XSS blockieren
    ↓
NACLs (Paketfilter) → IP-Ranges und Ports filtern
    ↓
Security Groups (Stateful) → nur erlaubte Verbindungen
    ↓
EC2-Instanz
```

Kein einzelner Firewall-Typ ist ausreichend — man braucht mehrere Schichten!

---

## Selbstreflexion

**Größte Erkenntnis Access Control:**
RBAC ist das effektivste Modell für skalierbare Systeme — AWS IAM basiert vollständig darauf. Das Least-Privilege-Prinzip ist die wichtigste Sicherheitsregel.

**Größte Erkenntnis Firewalls:**
Kein einzelner Firewall-Typ reicht aus. In AWS kombiniert man NACLs + Security Groups + WAF für mehrschichtige Sicherheit — Defense in Depth.

**Verbindung zur Praxis:**
- fail2ban auf dem ThinkPad → dynamische IP-Sperrung nach Brute-Force → praktischer Firewall-Mechanismus
- TryHackMe BruteIt → SSH Brute-Force → genau das was Firewalls verhindern sollen
