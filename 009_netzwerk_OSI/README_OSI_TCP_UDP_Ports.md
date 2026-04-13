# Aufgabe: OSI-Modell, TCP/UDP & Ports
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

---

## Teil 1 — Das OSI-Modell

### 1.1 Überblick

**OSI = Open Systems Interconnection**

Die 7 Schichten in der richtigen Reihenfolge:

| Nr. | Schicht | Englisch |
|---|---|---|
| 1 | Physikalische Schicht | Physical |
| 2 | Sicherungsschicht | Data Link |
| 3 | Vermittlungsschicht | Network |
| 4 | Transportschicht | Transport |
| 5 | Sitzungsschicht | Session |
| 6 | Darstellungsschicht | Presentation |
| 7 | Anwendungsschicht | Application |

**Eselsbrücke (von 1→7):**
**P**lease **D**o **N**ot **T**hrow **S**ausage **P**izza **A**way

---

### Grundprinzip: Enkapsulierung

Jede Schicht fügt beim Senden ihren eigenen Header hinzu und entfernt ihn beim Empfangen.

```
SENDEN (7→1):
Schicht 7: [HTTP-Daten]
Schicht 6: [Verschlüsselung][HTTP-Daten]
Schicht 5: [Session-ID][Verschlüsselung][HTTP-Daten]
Schicht 4: [TCP-Header/Ports][Session][Verschlüsselung][HTTP-Daten]
Schicht 3: [IP-Header][TCP-Header][Session][Verschlüsselung][HTTP-Daten]
Schicht 2: [MAC-Header][IP-Header][TCP-Header][Session][Verschlüsselung][HTTP-Daten]
Schicht 1: elektrische/optische/Funksignale

EMPFANGEN (1→7):
Jede Schicht liest und entfernt ihren eigenen Header und gibt den Rest an die nächste Schicht weiter.
```

---

### 1.2 Funktionen jeder Schicht

---

#### Schicht 1 — Physical (Physikalische Schicht)

**Aufgabe:** Übertragung von rohen Bits als physikalische Signale.

**Beim Senden (7→1):**
- Wandelt Bits in elektrische (Kabel), optische (Glasfaser) oder Funksignale (Wi-Fi) um

**Beim Empfangen (1→2):**
- Empfängt physikalische Signale und wandelt sie in Bits `0` und `1` um

**Zuständiges Modul:** Transceiver der Netzwerkkarte (NIC)

**Protokolle/Technologien:** Ethernet-Kabel, Glasfaser, Wi-Fi (802.11), Bluetooth, USB

**Analogie:** Die Straße, auf der die LKWs fahren — sie transportiert ohne zu interpretieren.

---

#### Schicht 2 — Data Link (Sicherungsschicht)

**Aufgabe:** Kommunikation im lokalen Netzwerk über MAC-Adressen.

**Beim Senden (3→2):**
- Empfängt Daten + MAC-Zieladresse von Schicht 3 (via ARP)
- Fügt MAC-Header hinzu (Quelle + Ziel)
- Überprüft Integrität via CRC
- Gibt an Schicht 1 weiter

**Beim Empfangen (1→3):**
- Liest die MAC-Zieladresse
- MAC = eigene ✅ → entfernt MAC-Header, weiter an Schicht 3
- MAC ≠ eigene ❌ → Frame wird ignoriert und verworfen

**Zuständiges Modul:** NIC (Network Interface Card) + Treiber

**Protokolle:** Ethernet, Wi-Fi (802.11)

**Analogie:** Der Briefträger im Gebäude — er kennt alle Wohnungen (MAC), kann aber das Gebäude nicht verlassen.

**Wichtig:** Der **Switch** arbeitet auf Schicht 2. Die Fritzbox enthält Switch (L2) + Router (L3) in einem Gerät. Im **Promiscuous-Modus** (z.B. Wireshark) akzeptiert die NIC alle Frames, auch fremde.

---

#### Schicht 3 — Network (Vermittlungsschicht)

**Aufgabe:** Routing zwischen Netzwerken über IP-Adressen.

**Beim Senden (4→3):**
- Konsultiert die Routingtabelle (`ip route`)
- IP-Ziel im lokalen Netz? → Direktverbindung
- IP-Ziel außerhalb? → über Gateway (z.B. Fritzbox)
- Nutzt **ARP** um die MAC-Adresse zur IP zu finden
- Fügt IP-Header hinzu

**Beim Empfangen (2→4):**
- Liest IP-Zieladresse
- IP = eigene ✅ → entfernt IP-Header, weiter an Schicht 4
- IP ≠ eigene → bin ich ein Router? Wenn ja: weiterleiten, sonst: verwerfen

**Zuständige Module:**
- **IP-Stack** (Linux-Kernel) → Routing, IP-Prüfung
- **ARP** → löst IP → MAC auf (nur das!)
- **ICMP** → Netzwerkdiagnose (`ping`, `traceroute`)

**Nützliche Befehle:**
```bash
ip route    # Routingtabelle anzeigen
arp -n      # ARP-Tabelle anzeigen (IP → MAC)
ping 8.8.8.8  # ICMP-Test
```

**Analogie:** Die nationale Post — sie leitet Pakete zwischen Städten weiter (IP). Der Router arbeitet hier.

---

#### Schicht 4 — Transport (Transportschicht)

**Aufgabe:** Segmentierung, Reassemblierung, Ports und Zuverlässigkeit.

**Beim Senden (5→4):**
- Zerlegt große Daten in Segmente
- Fügt Quell- und Zielport hinzu
- Wählt TCP (zuverlässig) oder UDP (schnell)
- Gibt an Schicht 3 weiter

**Beim Empfangen (3→5):**
- Liest Ports → welche Anwendung?
- Reassembliert Segmente in der richtigen Reihenfolge (TCP)
- Prüft ob alle Segmente angekommen sind (TCP)
- Entfernt TCP/UDP-Header

**Zuständiges Modul:** TCP/IP-Stack des Linux-Kernels

```bash
ss -tulnp    # offene Ports anzeigen
```

**Protokolle:** TCP, UDP

**Wichtig:** IP (Schicht 3) + Port (Schicht 4) identifizieren jeden Datenstrom eindeutig:
```
192.168.178.144:52341 ↔ 142.250.185.46:443  → Google
192.168.178.144:52342 ↔ 208.65.153.238:443  → YouTube
```

---

#### Schicht 5 — Session (Sitzungsschicht)

**Aufgabe:** Öffnen, Aufrechterhalten und Schließen von Kommunikationssitzungen.

**Beim Senden:**
- Öffnet eine Sitzung falls noch keine existiert
- Kennzeichnet die Nachricht mit dem Sitzungskontext
- Gibt an Schicht 6 weiter

**Beim Empfangen:**
- Identifiziert zu welcher Sitzung die Nachricht gehört
- Prüft ob die Sitzung noch gültig ist
- Gibt an Schicht 6 weiter

**Zuständige Module:** OpenSSL (TLS-Sitzungen), libpam (Authentifizierungssitzungen)

**Protokolle:** NetBIOS, RPC, PPTP, HTTP-Sessions via Cookies

**Beispiel:**
```
Browser mit 3 Tabs:
Tab 1 → google.com   → Sitzung A
Tab 2 → youtube.com  → Sitzung B
Tab 3 → github.com   → Sitzung C
```
Jeder Tab hat seine eigene Sitzung — keine Vermischung!

**Analogie:** Die Telefonvermittlung — öffnet die Leitung, hält die Verbindung aufrecht, legt auf wenn fertig.

---

#### Schicht 6 — Presentation (Darstellungsschicht)

**Aufgabe:** Verschlüsselung, Kodierung und Komprimierung.

**Beim Senden (7→6):**
- Komprimiert die Daten
- Kodiert (UTF-8, ASCII, Base64...)
- Verschlüsselt (AES, RSA, TLS...)

**Beim Empfangen (5→7):**
- Entschlüsselt
- Dekodiert
- Dekomprimiert
- Gibt lesbare Daten an Schicht 7

**Zuständige Module:** OpenSSL (Verschlüsselung), Codecs (Audio/Video-Komprimierung)

**Protokolle/Formate:** TLS/SSL, UTF-8, ASCII, Base64, JPEG, PNG, MP4

**Wichtig:** Verschlüsselung (Schicht 6) und Transportprotokoll (Schicht 4) sind unabhängig voneinander:
```
HTTPS + TCP → verschlüsselt + zuverlässig
HTTPS + UDP → verschlüsselt + schnell (z.B. Netflix mit QUIC)
```
Die Anwendung (Schicht 7) entscheidet ob verschlüsselt wird — nicht das Transportprotokoll!

---

#### Schicht 7 — Application (Anwendungsschicht)

**Aufgabe:** Direkte Schnittstelle zum Benutzer und den Anwendungen.

**Beim Senden:**
- Benutzer führt eine Aktion aus (Klick, Anfrage, E-Mail...)
- Anwendung formatiert die Anfrage gemäß ihrem Protokoll

**Beim Empfangen:**
- Empfängt Daten von Schicht 6
- Interpretiert und zeigt dem Benutzer an

**Zuständiges Modul:** Die Anwendung selbst (Browser, SSH-Client, E-Mail-Client...)

**Protokolle:**

| Protokoll | Verwendung |
|---|---|
| HTTP/HTTPS | Webnavigation |
| SMTP/IMAP/POP3 | E-Mail |
| FTP/SFTP | Dateiübertragung |
| DNS | Namensauflösung |
| DHCP | IP-Adressvergabe |
| SSH | Sichere Fernverbindung |

---

### Gesamtübersicht

```
┌──────────────────────────────────────────────────────────┐
│  7  Anwendung      │ HTTP, SSH, DNS, SMTP  │ Anwendung   │
│  6  Darstellung    │ TLS, UTF-8, JPEG      │ OpenSSL     │
│  5  Sitzung        │ Sessions, Cookies     │ libpam      │
│  4  Transport      │ TCP, UDP, Ports       │ TCP/IP-Stack│
│  3  Vermittlung    │ IP, ARP, ICMP         │ IP-Stack    │
│  2  Sicherung      │ MAC, Ethernet, WiFi   │ NIC         │
│  1  Physikalisch   │ Kabel, Signale, Wellen│ Transceiver │
└──────────────────────────────────────────────────────────┘
```

### Relevanz für Cloud-Architektur (AWS)

| OSI-Schicht | AWS-Entsprechung |
|---|---|
| Schicht 2 | VPC, Subnets, ENI |
| Schicht 3 | Route Tables, NAT Gateway |
| Schicht 4 | Security Groups (Port-Regeln) |
| Schicht 7 | Application Load Balancer, API Gateway |

---

## Teil 2 — TCP und UDP

### 2.1 Grundlegende Unterschiede

| Merkmal | TCP | UDP |
|---|---|---|
| Verbindungsaufbau | 3-Wege-Handshake | Keine Verbindung |
| Zuverlässigkeit | Garantiert | Nicht garantiert |
| Reihenfolge der Pakete | Garantiert | Nicht garantiert |
| Neuübertragung bei Verlust | Ja | Nein |
| Geschwindigkeit | Langsamer | Schneller |
| Flusskontrolle | Ja | Nein |

**Wichtig:** TCP ≠ Verschlüsselung!
- **TCP** → garantiert vollständige und geordnete Lieferung
- **TLS/SSL** (Schicht 6) → übernimmt die Verschlüsselung

Beide sind unabhängig voneinander!

---

### 2.2 Anwendungsfälle in der Praxis

**TCP — wenn Vollständigkeit wichtiger ist als Geschwindigkeit:**

| Anwendung | Begründung |
|---|---|
| HTTPS | Eine unvollständige Webseite ist unbrauchbar |
| SSH | Ein abgeschnittener Befehl kann gefährlich sein |
| E-Mail (SMTP) | Eine halb empfangene E-Mail ergibt keinen Sinn |
| Dateiübertragung (FTP) | Eine beschädigte Datei ist unbrauchbar |

**UDP — wenn Geschwindigkeit wichtiger ist als Vollständigkeit:**

| Anwendung | Begründung |
|---|---|
| Video-Streaming (Netflix) | Ein verlorenes Paket = kaum sichtbarer Pixelfehler |
| Videoanrufe (Zoom, Teams) | Verzögerung durch Neuübertragung wäre schlimmer |
| Online-Spiele | Position eines Spielers vor 500ms ist wertlos |
| DNS | Einfache Anfrage/Antwort, keine Verbindung nötig |

**Selbstreflexion — Online-Spiel:**
Für ein Online-Spiel würde ich **UDP** für Echtzeit-Daten (Spielerpositionen, Bewegungen) und **TCP** für kritische Daten (Chat, Punktestand, Transaktionen) verwenden. Geschwindigkeit und Synchronität sind bei Spielbewegungen wichtiger als vollständige Datenlieferung — ein verlorenes Positionspaket ist weniger schlimm als eine Verzögerung durch Neuübertragung.

---

## Teil 3 — Ports

### 3.1 Was ist ein Port?

Ein Port ist der **Kanal**, über den eine Anwendung kommuniziert. Er ermöglicht es einem Computer, mehrere Aufgaben gleichzeitig zu erledigen, indem verschiedene Ports verschiedenen Anwendungen zugewiesen werden.

```
IP-Adresse → identifiziert die Maschine
Port       → identifiziert die Anwendung auf der Maschine
```

**Analogie:**
```
IP   = Gebäudeadresse
Port = Wohnungsnummer
```

Ohne Ports würde ein Computer nicht wissen, ob ein eingehendes Paket für den Browser, den SSH-Client oder den Webserver bestimmt ist.

---

### 3.2 Well-Known Ports (unter 1024)

| Port | Protokoll | Dienst |
|---|---|---|
| 22 | TCP | SSH — sichere Fernverbindung |
| 25 | TCP | SMTP — E-Mail (unverschlüsselt) |
| 53 | UDP/TCP | DNS — Namensauflösung |
| 80 | TCP | HTTP — Webnavigation |
| 443 | TCP | HTTPS — verschlüsselte Webnavigation |
| 465 | TCP | SMTP — E-Mail (verschlüsselt) |
| 3306 | TCP | MySQL — Datenbank |
| 5432 | TCP | PostgreSQL — Datenbank |
| 3389 | TCP | RDP — Remote Desktop (Windows) |
| 6443 | TCP | Kubernetes API |

**Relevanz für AWS:** Security Groups konfigurieren genau diese Ports — Port 443 für HTTPS öffnen, Port 22 für SSH, Port 5432 für PostgreSQL usw.

---

## Zusammenfassung

| Thema | Kernaussage |
|---|---|
| OSI-Modell | 7 Schichten, jede mit eigenem Header, zwei Richtungen |
| TCP | Zuverlässig, geordnet, langsamer — für kritische Daten |
| UDP | Schnell, unzuverlässig — für Echtzeit-Anwendungen |
| Ports | Identifizieren Anwendungen auf einer Maschine |
| Verschlüsselung | Schicht 6 (TLS) — unabhängig von TCP/UDP |
