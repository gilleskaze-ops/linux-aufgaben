# Aufgabe: IPv4, IPv6 & DNS
**Datum:** 09.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student
> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions 
> mit KI-Unterstützung — Konzepte wurden diskutiert, 
> hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — IPv4

### 1.1 IPv4-Adressstruktur

Eine IPv4-Adresse besteht aus **32 Bits** — aufgeteilt in 4 Oktette (je 8 Bits), getrennt durch Punkte:

```
192  .  168  .   1   .   0
8Bit    8Bit    8Bit    8Bit
= 32 Bits gesamt
```

**Zwei Hauptbestandteile:**

| Teil | Funktion |
|---|---|
| **Netzwerkteil** | Identifiziert das Netzwerk — gruppiert Maschinen im selben Netzwerk |
| **Hostteil** | Identifiziert eine einzelne Maschine innerhalb des Netzwerks |

```
192.168.1.0/24
|---------|  |
 Netzwerk    Host
 (24 Bits)   (8 Bits)
```

---

### IPv4-Adressklassen

| Klasse | Netzwerkbits | Hostbits | Hosts/Netzwerk | Adressbereich |
|---|---|---|---|---|
| **A** | 8 Bits | 24 Bits | ~16 Millionen | 1.0.0.0 → 126.0.0.0 |
| **B** | 16 Bits | 16 Bits | 65.534 | 128.0.0.0 → 191.255.0.0 |
| **C** | 24 Bits | 8 Bits | 254 | 192.0.0.0 → 223.255.255.0 |

```
Klasse A : [Netzwerk 8 Bits][Host 24 Bits] → wenige Netze, riesig
Klasse B : [Netzwerk 16 Bits][Host 16 Bits] → ausgewogen
Klasse C : [Netzwerk 24 Bits][Host 8 Bits] → viele Netze, klein
```

---

### Besondere IPv4-Adressen

| Adresse | Typ | Verwendung |
|---|---|---|
| Erste IP im Block | Netzwerkadresse | Identifiziert das Netzwerk (nicht nutzbar) |
| Letzte IP im Block | Broadcast | Sendet an alle Geräte im Netzwerk |
| 127.0.0.1 | Loopback | Maschine kommuniziert mit sich selbst |
| 0.0.0.0 | Standardadresse | "Alle Interfaces" (sichtbar in `ss -tulnp`) |
| 169.254.x.x | APIPA | Automatisch vergeben wenn DHCP nicht antwortet |

**Private Adressen (nicht im Internet routbar):**

```
Klasse A : 10.0.0.0/8        → Große private Netze (AWS VPC!)
Klasse B : 172.16.0.0/12     → Mittlere Netze
Klasse C : 192.168.0.0/16    → Heimnetzwerke (Fritzbox!)
```

---

### 1.2 Subnetting

**Was ist Subnetting?**

Subnetting ist die Aufteilung eines großen Netzwerks in kleinere Teilnetzwerke. Es dient zur:
- **Organisation** → Netzwerk nach Abteilungen strukturieren
- **Sicherheit** → Sensitive Maschinen in private Subnetze isolieren
- **Performance** → Broadcast-Traffic reduzieren
- **Effizienz** → IP-Adressen nicht verschwenden
- **Planung** → Netzwerkarchitektur für Wachstum vorbereiten

**Die Subnetzmaske** trennt Netzwerk- und Hostteil:
```
/24 → 24 Bits Netzwerk, 8 Bits Host
/26 → 26 Bits Netzwerk, 6 Bits Host (2 Bits ausgeliehen)
```

---

**Berechnungsbeispiel: 192.168.1.0/24 → 4 Subnetze**

```
Schritt 1: Wie viele Bits ausleihen?
           4 Subnetze → 2² = 4 → 2 Bits ausleihen

Schritt 2: Neue Maske → /24 + 2 = /26

Schritt 3: Hosts pro Subnetz → 2⁶ - 2 = 62 Hosts

Schritt 4: Blockgröße → 256 / 4 = 64 Adressen pro Block
```

| Subnetz | Netzwerk-IP | Erste Host-IP | Letzte Host-IP | Broadcast |
|---|---|---|---|---|
| 1 | 192.168.1.0/26 | 192.168.1.1 | 192.168.1.62 | 192.168.1.63 |
| 2 | 192.168.1.64/26 | 192.168.1.65 | 192.168.1.126 | 192.168.1.127 |
| 3 | 192.168.1.128/26 | 192.168.1.129 | 192.168.1.190 | 192.168.1.191 |
| 4 | 192.168.1.192/26 | 192.168.1.193 | 192.168.1.254 | 192.168.1.255 |

**Allgemeine Regel:**

| Gewünschte Subnetze | Bits ausleihen | Neue Maske (/24 Basis) |
|---|---|---|
| 2 | 1 | /25 |
| 3-4 | 2 | /26 |
| 5-8 | 3 | /27 |
| 9-16 | 4 | /28 |

---

**Cloud-Anwendung (AWS VPC):**

In AWS wird immer von den **Host-Anforderungen** ausgegangen:

```
Beispiel: VPC 10.0.0.0/16, mind. 500 Hosts/Subnetz

Schritt 1: 2⁹ = 512 → 9 Bits für Hosts → Maske /23
Schritt 2: 32 - 9 = /23 → Blockgröße 512 Adressen
Schritt 3: /16 → /23 = 7 Bits ausgeliehen → 2⁷ = 128 Subnetze verfügbar

Ergebnis:
├── Public Subnet 1  : 10.0.0.0/23  (510 Hosts)
├── Public Subnet 2  : 10.0.2.0/23  (510 Hosts)
├── Public Subnet 3  : 10.0.4.0/23  (510 Hosts)
├── Public Subnet 4  : 10.0.6.0/23  (510 Hosts)
├── Private Subnet 1 : 10.0.8.0/23  (510 Hosts)
├── Private Subnet 2 : 10.0.10.0/23 (510 Hosts)
├── Private Subnet 3 : 10.0.12.0/23 (510 Hosts)
└── Private Subnet 4 : 10.0.14.0/23 (510 Hosts)
```

---

## Aufgabe 2 — IPv6

### 2.1 IPv6-Adressstruktur

Eine IPv6-Adresse besteht aus **128 Bits** — aufgeteilt in 8 Gruppen zu je 16 Bits, hexadezimal geschrieben und durch `:` getrennt:

```
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

**Vergleich IPv4 vs IPv6:**

| | IPv4 | IPv6 |
|---|---|---|
| Bits | 32 | 128 |
| Format | Dezimal | Hexadezimal |
| Trenner | Punkt (.) | Doppelpunkt (:) |
| Adressen | ~4 Milliarden | 340 Undezillionen |

---

### Adresskomprimierung

**Regel 1 — Führende Nullen weglassen:**
```
0db8 → db8
0000 → 0
00ab → ab
```

**Regel 2 — Aufeinanderfolgende Null-Gruppen durch `::` ersetzen:**
```
2001:0db8:0000:0000:0000:0000:0370:7334
→ 2001:db8::370:7334
```

**Wichtig:** `::` darf nur **einmal** pro Adresse vorkommen!

**Vollständiges Beispiel:**
```
Original  : 2001:0db8:85a3:0000:0000:8a2e:0370:7334
Schritt 1 : 2001:db8:85a3:0:0:8a2e:370:7334
Schritt 2 : 2001:db8:85a3::8a2e:370:7334
```

---

### IPv6-Adresstypen

| Typ | Beschreibung | Analogie |
|---|---|---|
| **Unicast** | Ein Sender → ein Empfänger | E-Mail an eine Person |
| **Multicast** | Ein Sender → Gruppe von Empfängern | E-Mail-Verteilerliste |
| **Anycast** | Ein Sender → nächster Empfänger der Gruppe | Notruf (nächste Zentrale antwortet) |

**Anycast-Beispiel:** Google DNS `8.8.8.8` — Hunderte Server weltweit teilen diese Adresse, immer der geografisch nächste antwortet.

---

### 2.2 Vorteile von IPv6 gegenüber IPv4

**1. Riesiger Adressraum**
```
IPv4 : 2³²  = ~4 Milliarden Adressen → erschöpft!
IPv6 : 2¹²⁸ = 340 Undezillionen Adressen → praktisch unbegrenzt
```

**2. Kein NAT mehr notwendig**
Jedes Gerät kann eine eigene öffentliche IP-Adresse haben — keine "Versteckung" hinter einer einzigen IP mehr nötig.

**3. Integrierte Sicherheit (IPsec)**
IPsec ist in IPv6 nativ eingebaut — Verschlüsselung ist Teil des Protokolls, nicht optional.

**4. Automatische Konfiguration (SLAAC)**
Geräte können sich selbst konfigurieren ohne DHCP — sie generieren ihre Adresse automatisch aus ihrer MAC-Adresse.

**5. Bessere Performance**
Vereinfachte Header → Router verarbeiten Pakete schneller.

---

## Aufgabe 3 — DNS

### 3.1 Zweck von DNS

**DNS = Domain Name System**

DNS übersetzt menschenlesbare Domainnamen in IP-Adressen:
```
google.com → 142.250.185.46
```

Ohne DNS müsste man sich alle IP-Adressen merken — praktisch unmöglich. DNS ist das **Telefonbuch des Internets**.

**Protokoll:** UDP/TCP, Port **53**, Schicht **7 (Application)**

---

### 3.2 DNS-Auflösungsprozess

```
Benutzer tippt: google.com
        ↓
1. Browser-Cache
   → IP bereits gespeichert? ✅ → sofortige Antwort
   → Nicht gefunden ❌ → weiter

2. Lokaler Cache (OS) + /etc/hosts
   → Nicht gefunden ❌ → weiter

3. Recursive DNS Server (z.B. 8.8.8.8 oder Fritzbox)
   → "Ich suche für dich"
   → Eigenen Cache prüfen
   → Nicht gefunden ❌ → weiter

4. Root DNS Server
   → "google.com kenne ich nicht"
   → "Aber für .com → geh zu diesem TLD-Server"

5. TLD Server (.com)
   → "Für google.com → geh zu diesem Authoritative Server"

6. Authoritative DNS Server
   → "google.com = 142.250.185.46" ✅
   → Endgültige Antwort!

7. Recursive Server gibt Antwort zurück
   → Speichert Ergebnis im Cache
   → Browser erhält IP-Adresse und speichert auch im Cache

Gesamtdauer: < 50 Millisekunden!
```

**Beteiligte Komponenten:**

| Komponente | Rolle |
|---|---|
| **Browser/OS Cache** | Erste Anlaufstelle — schnellste Antwort |
| **Recursive DNS Server** | Macht die Arbeit, fragt andere Server |
| **Root DNS Server** | Kennt die TLD-Server |
| **TLD Server** | Zuständig für .com, .de, .fr... |
| **Authoritative Server** | Hat die endgültige Antwort |

---

## Zusammenfassung

| Thema | Kernaussage |
|---|---|
| IPv4 | 32 Bits, 4 Oktette, Klassen A/B/C, erschöpft |
| Subnetting | Netzwerk aufteilen → Sicherheit, Organisation, Effizienz |
| IPv6 | 128 Bits, Hexadezimal, praktisch unbegrenzte Adressen |
| DNS | Übersetzt Domainnamen → IP-Adressen, Port 53, Schicht 7 |
