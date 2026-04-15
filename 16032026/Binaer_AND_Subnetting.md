# Aufgabe: Binärzahlen, AND-Operation & Subnetting
**Datum:** 16.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI)  
**Benutzer:** dci-student

> **Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Task 1 — Dezimal ↔ Binär Konvertierung

### Methode

Eine 8-Bit Binärzahl basiert auf Zweierpotenzen:

```
128   64   32   16    8    4    2    1
 2⁷   2⁶   2⁵   2⁴   2³   2²   2¹   2⁰
```

**Dezimal → Binär:** Prüfe von links nach rechts ob die Zweierpotenz in die Zahl passt. Wenn ja → 1 und subtrahiere, wenn nein → 0.

**Binär → Dezimal:** Addiere alle Zweierpotenzen wo eine 1 steht.

---

### 1.1 Dezimal → Binär

**123 → Binär:**
```
128  64  32  16   8   4   2   1
  0   1   1   1   1   1   0   1

123 - 64 = 59 → 1
 59 - 32 = 27 → 1
 27 - 16 = 11 → 1
 11 -  8 =  3 → 1
  3 -  2 =  1 → 1
  1 -  1 =  0 → 1

= 01111101
```

**42 → Binär:**
```
128  64  32  16   8   4   2   1
  0   0   1   0   1   0   1   0

42 - 32 = 10 → 1
10 -  8 =  2 → 1
 2 -  2 =  0 → 1

= 00101010
```

**200 → Binär:**
```
128  64  32  16   8   4   2   1
  1   1   0   0   1   0   0   0

200 - 128 = 72 → 1
 72 -  64 =  8 → 1
  8 -   8 =  0 → 1

= 11001000
```

---

### 1.2 Binär → Dezimal

**11001010 → Dezimal:**
```
128  64  32  16   8   4   2   1
  1   1   0   0   1   0   1   0

128 + 64 + 8 + 2 = 202
```

**00110100 → Dezimal:**
```
128  64  32  16   8   4   2   1
  0   0   1   1   0   1   0   0

32 + 16 + 4 = 52
```

**10101010 → Dezimal:**
```
128  64  32  16   8   4   2   1
  1   0   1   0   1   0   1   0

128 + 32 + 8 + 2 = 170
```

---

### 1.3 Reflexion

Die Methode Binär → Dezimal ist intuitiver — man addiert einfach die Zweierpotenzen wo eine 1 steht. Bei Dezimal → Binär muss man systematisch von der größten Zweierpotenz subtrahieren, was mehr Konzentration erfordert.

---

## Task 2 — Binäre AND-Operation mit IP-Adressen

### 2.1 Grundregel der AND-Operation

Die AND-Operation ist eine binäre logische Operation:

```
0 AND 0 = 0
0 AND 1 = 0
1 AND 0 = 0
1 AND 1 = 1  ← nur dieser Fall ergibt 1
```

**Regel:** Nur wenn **beide** Bits 1 sind, ist das Ergebnis 1. Wie eine Tür die nur aufgeht wenn beide Schlüssel gleichzeitig verwendet werden.

---

### 2.2 AND-Operation: IP-Adresse und Subnetzmaske

**Beispiel: `192.168.1.100` mit Maske `255.255.255.0`**

```
IP     : 11000000.10101000.00000001.01100100
Maske  : 11111111.11111111.11111111.00000000
AND    : 11000000.10101000.00000001.00000000
Netz   : 192.168.1.0
```

**Warum AND?**
- Die `1` in der Maske → **behalten** (Netzwerkteil)
- Die `0` in der Maske → **löschen** (Hostteil)

---

### 2.3 Netzwerk- und Hostteil

```
192.168.1  .  100
└─────────┘   └─┘
  Netzwerk     Host
  24 Bits      8 Bits
```

- **Netzwerkteil (192.168.1)** → identifiziert das Netzwerk, alle Maschinen im selben Netz teilen diesen Teil
- **Hostteil (100)** → identifiziert die einzelne Maschine innerhalb des Netzwerks
- Gültige Hosts: **192.168.1.1** bis **192.168.1.254**

---

## Task 3 — Zweck des Subnettings

### 3.1 Warum Subnetting?

Subnetting unterteilt ein großes Netzwerk in kleinere Teilnetzwerke um:
- Netzwerke nach **Abteilungen oder Funktionen zu organisieren**
- **IP-Adressen effizient zu nutzen** (kein Verschwendung)
- Die **Sicherheit zu erhöhen** (Trennung öffentlich/privat)
- Die **Performance zu verbessern** (weniger Broadcast-Traffic)
- Das Netzwerk **skalierbar zu planen**

---

### 3.2 Vor- und Nachteile

**Vorteile:**

- **Bessere Performance** → weniger Broadcast-Traffic durch kleinere Netze
- **Erhöhte Sicherheit** → öffentliche und private IPs getrennt — z.B. Load Balancer im Public Subnet, EC2 im Private Subnet
- **Effiziente Ressourcenplanung** → kein IP-Verschwendung, Netzwerk wächst kontrolliert
- **Organisation** → Abteilungen (Entwickler, HR, Management) erhalten eigene Subnetze

**Nachteil:**

- **IP-Verlust** → jedes Subnetz verliert 2 Adressen (Netzwerkadresse + Broadcast) — je mehr Subnetze, desto mehr Adressen gehen verloren
- **Komplexität** → mehr Subnetze = mehr Konfigurationsaufwand (Routen, Security Groups, Firewalls)

---

### 3.3 Praxisszenarien

**Szenario 1 — Cloud AWS:**
```
Internet → Load Balancer (Public Subnet)
                ↓
           EC2-Instanzen (Private Subnet) → nie direkt vom WAN erreichbar
                ↓
           Datenbank (DB Subnet isoliert)
```

**Szenario 2 — Unternehmesnetzwerk:**
```
Entwickler  → großes Subnetz /23 (510 Hosts, hohe Priorität)
HR          → kleines Subnetz /26 (62 Hosts)
Management  → kleines Subnetz /27 (30 Hosts)
```

---

## Task 4 — Subnetting in der Praxis

### Aufgabe: `172.16.50.25/22`

---

### 4.1 Netzwerk- und Hostbits

```
/22 → 22 Bits Netzwerk + 10 Bits Host = 32 Bits gesamt
```

---

### 4.2 Subnetzmaske berechnen

22 Bits auf 1 setzen, Rest auf 0:

```
11111111.11111111.11111100.00000000
255     .255     .252     .0

→ Subnetzmaske: 255.255.252.0
```

---

### 4.3 Netzwerkadresse berechnen (AND-Operation)

```
IP     : 10101100.00010000.00110010.00011001
Maske  : 11111111.11111111.11111100.00000000
AND    : 10101100.00010000.00110000.00000000
```

**Wichtig:** Der 3. Oktet:
```
50  = 00110010
252 = 11111100
AND = 00110000 = 48  ← nicht 50!
```

Die letzten 2 Bits von 50 werden durch die Maske gelöscht!

```
Netzwerkadresse: 172.16.48.0
```

---

### 4.4 Broadcast-Adresse berechnen

Alle Hostbits auf 1 setzen:

```
Netzwerk  : 10101100.00010000.00110000.00000000
Broadcast : 10101100.00010000.00110011.11111111

3. Oktet: 00110011 = 51
4. Oktet: 11111111 = 255

Broadcast: 172.16.51.255
```

---

### 4.5 Anzahl nutzbarer Hosts

```
10 Hostbits → 2¹⁰ = 1024 Adressen
1024 - 2 = 1022 nutzbare Hosts
(-1 Netzwerkadresse, -1 Broadcast)
```

---

### Zusammenfassung: `172.16.50.25/22`

| Parameter | Wert |
|---|---|
| Subnetzmaske | 255.255.252.0 |
| Netzwerkadresse | 172.16.48.0 |
| Erster Host | 172.16.48.1 |
| Letzter Host | 172.16.51.254 |
| Broadcast | 172.16.51.255 |
| Nutzbare Hosts | 1022 |

---

## Selbstreflexion

- **Was habe ich heute gelernt?** Die AND-Operation zwischen IP und Subnetzmaske zeigt präzise wie Router Netzwerk- und Hostteil trennen. Besonders beim /22 wird klar warum man nicht einfach die ersten Oktette als Netzwerkteil annehmen kann.
- **Größte Herausforderung:** Die AND-Operation beim 3. Oktet von /22 — der Oktet ist weder vollständig Netzwerk noch vollständig Host, was zu Fehlern führen kann wenn man nicht sorgfältig rechnet.
- **Nächste Schritte:** Weitere Subnetting-Übungen mit komplexeren Szenarien wie AWS VPC Design mit mehreren Availability Zones.
