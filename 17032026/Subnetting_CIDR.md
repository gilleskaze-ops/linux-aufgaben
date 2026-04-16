# Aufgabe: Subnetting, CIDR-Notation & Berechnungen
**Datum:** 17.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Aufgabe 1 — Zweck des Subnettings

### Warum Subnetting?

Subnetting unterteilt ein großes Netzwerk in kleinere Teilnetzwerke. Die Hauptgründe:

**Effizienz:**
CIDR hat das starre Klassensystem (A/B/C) abgelöst. Früher musste eine Firma mit 300 Maschinen eine Klasse B nehmen (65.534 Hosts!) — enormer Verschwendung. Mit CIDR nimmt man genau so viele Adressen wie benötigt.

```
Ohne CIDR : 300 Maschinen → Klasse B → 65.534 Hosts → 65.234 verschwendet ❌
Mit CIDR  : 300 Maschinen → /23 → 510 Hosts → minimale Verschwendung ✅
```

**Performance:**
Kleinere Subnetze = kleinere Broadcast-Domänen = weniger Broadcast-Traffic = bessere Netzwerkleistung.

**Sicherheit:**
Trennung von öffentlichen und privaten IP-Bereichen:
```
Internet → Load Balancer (Public Subnet)
                ↓
           EC2-Instanzen (Private Subnet) → nie direkt erreichbar
                ↓
           Datenbank (DB Subnet isoliert)
```

**Organisation:**
Abteilungen erhalten eigene Subnetze mit angepasster Größe:
```
Entwickler  → /23 (510 Hosts, hohe Priorität)
HR          → /26 (62 Hosts)
Management  → /27 (30 Hosts)
```

**Nachteile:**
- Jedes Subnetz verliert 2 Adressen (Netzwerkadresse + Broadcast)
- Mehr Subnetze = mehr Konfigurationsaufwand

---

## Aufgabe 2 — CIDR-Notation und Präfixlänge

### Was ist CIDR?

CIDR (Classless Inter-Domain Routing) gibt direkt die Anzahl der Netzwerkbits an und ermöglicht flexible Subnetzgrößen — im Gegensatz zum starren Klassensystem.

```
Klassisch : Klasse A = /8, Klasse B = /16, Klasse C = /24 (fest!)
CIDR      : /8 bis /32 — jede Präfixlänge ist möglich
```

---

### Präfixlänge → Dezimale Subnetzmaske

**Methode:** n Bits auf 1 setzen, Rest auf 0, dann in Dezimal umrechnen.

**/8:**
```
11111111.00000000.00000000.00000000
→ 255.0.0.0
```

**/19:**
```
11111111.11111111.11100000.00000000
→ 255.255.224.0
```

**/27:**
```
11111111.11111111.11111111.11100000
→ 255.255.255.224
```

**/30:**
```
11111111.11111111.11111111.11111100
→ 255.255.255.252
```

---

### Dezimale Subnetzmaske → Präfixlänge

**Methode:** Letzten relevanten Oktet in Binär umwandeln, alle 1-Bits zählen.

**255.255.255.192:**
```
192 = 11000000 → 2 Einsen im letzten Oktet
24 + 2 = /26
```

**255.255.0.0:**
```
→ 16 Einsen → /16
```

**255.255.255.240:**
```
240 = 11110000 → 4 Einsen im letzten Oktet
24 + 4 = /28
```

---

### Zusammenfassung CIDR-Konvertierungen

| CIDR | Binär (letztes relevantes Oktet) | Dezimale Maske |
|---|---|---|
| /8 | 11111111.00000000.00000000.00000000 | 255.0.0.0 |
| /19 | ...11100000.00000000 | 255.255.224.0 |
| /27 | ...11111111.11100000 | 255.255.255.224 |
| /30 | ...11111111.11111100 | 255.255.255.252 |
| /26 | ...11111111.11000000 | 255.255.255.192 |
| /16 | 11111111.11111111.00000000.00000000 | 255.255.0.0 |
| /28 | ...11111111.11110000 | 255.255.255.240 |

---

### Netzwerk- und Hostteil ableiten

```
IP : 192.168.10.50/27

/27 → 27 Bits Netzwerk, 5 Bits Host

Netzwerkteil : 192.168.10. + erste 3 Bits des letzten Oktets
Hostteil     : letzte 5 Bits des letzten Oktets

→ Hosts pro Subnetz : 2⁵ - 2 = 30
```

---

## Aufgabe 3 — Subnetze und Hosts berechnen

### Grundformeln

```
Anzahl Subnetze  = 2ⁿ        (n = geliehene Bits)
Hosts pro Subnetz = 2ʰ - 2   (h = Hostbits, -2 für Netz + Broadcast)
```

---

### Strategie-Übersicht

| Vorgabe | Strategie |
|---|---|
| "Teile in X Subnetze auf" | Von Subnetzen ausgehen → Bits leihen |
| "Mindestens X Hosts pro Subnetz" | Von Hosts ausgehen → Maske berechnen |
| Beide Bedingungen | Von Hosts ausgehen → Subnetze prüfen |

---

### Szenario A: 192.168.10.0/24 → 8 gleiche Subnetze

**Berechnung:**
```
8 Subnetze → 2³ = 8 → 3 Bits leihen
/24 + 3 = /27
Maske: 255.255.255.224
Hosts: 2⁵ - 2 = 30 pro Subnetz
Schrittweite: 32
```

**Alle 8 Subnetze:**

| Subnetz | Netzwerkadresse | Erster Host | Letzter Host | Broadcast |
|---|---|---|---|---|
| 1 | 192.168.10.0 | 192.168.10.1 | 192.168.10.30 | 192.168.10.31 |
| 2 | 192.168.10.32 | 192.168.10.33 | 192.168.10.62 | 192.168.10.63 |
| 3 | 192.168.10.64 | 192.168.10.65 | 192.168.10.94 | 192.168.10.95 |
| 4 | 192.168.10.96 | 192.168.10.97 | 192.168.10.126 | 192.168.10.127 |
| 5 | 192.168.10.128 | 192.168.10.129 | 192.168.10.158 | 192.168.10.159 |
| 6 | 192.168.10.160 | 192.168.10.161 | 192.168.10.190 | 192.168.10.191 |
| 7 | 192.168.10.192 | 192.168.10.193 | 192.168.10.222 | 192.168.10.223 |
| 8 | 192.168.10.224 | 192.168.10.225 | 192.168.10.254 | 192.168.10.255 |

---

### Szenario B: 172.16.0.0/16 → mindestens 500 Hosts pro Subnetz

**Berechnung:**
```
500 Hosts → 2⁹ = 512 → 9 Hostbits
32 - 9 = /23
Maske: 255.255.254.0

Geliehene Bits: 23 - 16 = 7
Mögliche Subnetze: 2⁷ = 128
Hosts pro Subnetz: 2⁹ - 2 = 510

Schrittweite 3. Oktet: 512 / 256 = +2
```

**Visualisierung der Maske:**
```
/16 (Ausgangspunkt):
11111111.11111111.00000000.00000000

/23 (neu):
11111111.11111111.11111110.00000000
                  ^^^^^^^ → 7 geliehene Bits → 2⁷ = 128 Subnetze
                         ^^^^^^^^^^ → 9 Hostbits → 2⁹-2 = 510 Hosts
```

**Subnetz 1 und Subnetz 10:**

| Subnetz | Netzwerkadresse | Erster Host | Letzter Host | Broadcast |
|---|---|---|---|---|
| 1 | 172.16.0.0 | 172.16.0.1 | 172.16.1.254 | 172.16.1.255 |
| 10 | 172.16.18.0 | 172.16.18.1 | 172.16.19.254 | 172.16.19.255 |

**Berechnung Subnetz 10:**
```
(10 - 1) × 2 = 18 → 3. Oktet = 18
→ 172.16.18.0/23
```

---

### Zusatzbeispiel: 172.16.0.0/16 → mindestens 1000 Hosts

```
1000 Hosts → 2¹⁰ = 1024 → 10 Hostbits
32 - 10 = /22
Maske: 255.255.252.0

Geliehene Bits: 22 - 16 = 6
Mögliche Subnetze: 2⁶ = 64
Hosts pro Subnetz: 2¹⁰ - 2 = 1022
Schrittweite: 1024 / 256 = +4
```

---

## Selbstreflexion

**Was habe ich heute gelernt?**
CIDR gibt die Netzwerkbits direkt an und ersetzt das starre Klassensystem. Die AND-Operation zwischen IP und Maske bestimmt die Netzwerkadresse. Bei Cloud-Szenarien geht man von den benötigten Hosts aus, nicht von der Anzahl der Subnetze.

**Größte Herausforderung:**
Die Unterscheidung zwischen "von Subnetzen ausgehen" und "von Hosts ausgehen" — je nach Aufgabenstellung muss man die richtige Strategie wählen.

**Nächste Schritte:**
AWS VPC Design mit mehreren Availability Zones und kombinierten Subnetting-Anforderungen.
