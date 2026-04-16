# ILP Networking – Routing, Routing-Protokolle und Gateway

**Lernmethode:** Erarbeitet durch interaktive Q&A-Sessions mit KI-Unterstützung — Konzepte wurden diskutiert, hinterfragt und praktisch angewendet.

---

## Glossar

| Abkürzung | Ausgeschriebener Begriff | Bedeutung |
|---|---|---|
| **AS** | Autonomous System | Ein Netzwerk unter einer einzigen administrativen Verwaltung (z.B. ein ISP oder ein Cloud-Anbieter) |
| **BGP** | Border Gateway Protocol | Routing-Protokoll zwischen Autonomous Systems – das Protokoll des Internets |
| **DHCP** | Dynamic Host Configuration Protocol | Protokoll zur automatischen IP-Adressvergabe |
| **FAI / ISP** | Fournisseur d'Accès à Internet / Internet Service Provider | Internetdienstanbieter (z.B. Deutsche Telekom) |
| **LAN** | Local Area Network | Lokales Netzwerk |
| **OSPF** | Open Shortest Path First | Dynamisches Routing-Protokoll für interne Netzwerke (intra-AS) |
| **RIP** | Routing Information Protocol | Einfaches, älteres dynamisches Routing-Protokoll |
| **VPC** | Virtual Private Cloud | Virtuelles privates Netzwerk in AWS |
| **WAN** | Wide Area Network | Weitverkehrsnetz (z.B. das Internet) |

---

## 1. Routing – Grundlagen

### Was ist Routing?

Routing ist der Mechanismus, durch den Datenpakete in einem Netzwerk von einem Absender zu einem Empfänger weitergeleitet werden. Ein **Router** (Netzwerkgerät zur Paketvermittlung) entscheidet an jedem Knotenpunkt, welchen Weg ein Paket als nächstes nehmen soll.

Ohne Routing würden Pakete ihr Ziel nicht finden — ähnlich wie Briefe ohne Postleitzahlen und Verteilzentren.

### Analogie: Die Briefpost

Stell dir vor, du schickst ein Paket von Deutschland nach Japan. Kein einziges Verteilzentrum kennt den gesamten Weg — jedes Zentrum kennt nur den nächsten Schritt. Genau so funktioniert Routing: Jeder Router kennt nur den nächsten Hop (Sprung) zum Ziel.

### Praktisches Beispiel

```bash
ip route show
```

Ausgabe auf dem ThinkPad L15:
```
default via 192.168.178.1 dev wlp0s20f3
192.168.178.0/24 dev wlp0s20f3 src 192.168.178.144
```

- `default via 192.168.178.1` → Alle unbekannten Pakete werden an die Fritzbox (Default Gateway) gesendet
- `192.168.178.0/24` → Lokale Geräte werden direkt erreicht (kein Router nötig)

---

## 2. Statisches vs. Dynamisches Routing

### Statisches Routing

Ein Administrator konfiguriert die Routen **manuell**. Die Routing-Tabelle ändert sich nicht automatisch.

**Analogie:** Eine handgezeichnete Papierkarte — nützlich und zuverlässig, aber sie aktualisiert sich nicht automatisch bei Straßensperrungen.

**Vorteile:**
- Vollständige Kontrolle über den Netzwerkpfad
- Kein Protokoll-Overhead
- Sicherheit und Vorhersehbarkeit

**Nachteile:**
- Kein automatisches Failover bei Ausfällen
- Schwer skalierbar bei großen Netzwerken
- Hoher manueller Verwaltungsaufwand

**Typischer Einsatz:** Kleine Netzwerke, AWS VPC Route Tables, Verbindung zu einem einzelnen Internet Gateway.

---

### Dynamisches Routing

Router **kommunizieren automatisch** miteinander und tauschen Routing-Informationen aus. Bei Änderungen im Netzwerk (z.B. Ausfall eines Links) wird die Tabelle automatisch aktualisiert.

**Analogie:** Ein Echtzeit-GPS-Navigationssystem — es kennt Staus, Umleitungen und berechnet den optimalen Weg neu.

**Vorteile:**
- Automatisches Failover
- Hoch skalierbar
- Geringer Verwaltungsaufwand bei großen Netzwerken

**Nachteile:**
- Komplexer zu konfigurieren
- Protokoll-Overhead (Router tauschen ständig Informationen aus)
- Weniger direkte Kontrolle über Pfade

**Typischer Einsatz:** Unternehmensnetze, ISP-Netzwerke, das gesamte Internet (BGP).

---

### Vergleichstabelle: Statisch vs. Dynamisch

| Merkmal | Statisches Routing | Dynamisches Routing |
|---|---|---|
| Konfiguration | Manuell durch Admin | Automatisch durch Protokoll |
| Flexibilität | Gering | Hoch |
| Skalierbarkeit | Klein bis mittel | Sehr groß |
| Konvergenz bei Ausfall | Keine automatische Reaktion | Automatische Neuberechnung |
| Verwaltungsaufwand | Hoch bei großen Netzen | Gering nach Ersteinrichtung |
| Sicherheit | Hoch (vollständige Kontrolle) | Geringer (Protokoll-Angriffsfläche) |
| Typischer Einsatz | Kleine Netze, AWS VPC | Unternehmensnetze, Internet |

---

## 3. Routing-Protokolle: RIP, OSPF und BGP

### RIP – Routing Information Protocol

- **Typ:** Distanzvektor-Protokoll
- **Metrik:** Anzahl der Hops (Sprünge) — jeder durchlaufene Router = 1 Hop
- **Maximale Hops:** 15 (ab 16 gilt das Ziel als unerreichbar)
- **Konvergenz:** Langsam (bis zu mehreren Minuten)
- **Einsatzbereich:** Sehr kleine, einfache Netzwerke; heute weitgehend veraltet

**Funktionsweise:** Jeder Router teilt seinen Nachbarn alle bekannten Routen mit. Der Weg mit den wenigsten Hops wird bevorzugt — unabhängig von der Leitungsqualität.

**Warum veraltet?** Ein Traceroute von Deutschland zu einem AWS-Server zeigt oft mehr als 15 Router — RIP wäre hier komplett unbrauchbar.

---

### OSPF – Open Shortest Path First

- **Typ:** Link-State-Protokoll
- **Metrik:** Kosten (Cost) basierend auf der Bandbreite des Links (10 Gbit/s = niedrige Kosten, 1 Mbit/s = hohe Kosten)
- **Algorithmus:** Dijkstra (kürzester Pfad)
- **Konvergenz:** Schnell (Sekunden)
- **Einsatzbereich:** Unternehmensnetze, Rechenzentren, **innerhalb eines AS**

**Funktionsweise:** Jeder Router baut eine vollständige Karte des gesamten Netzwerks auf (Link-State Database) und berechnet daraus den optimalen Weg zum Ziel.

**Analogie:** Ein GPS mit vollständiger Straßenkarte — kennt alle Verbindungen und wählt die schnellste Route basierend auf der Straßenqualität.

---

### BGP – Border Gateway Protocol

- **Typ:** Pfadvektor-Protokoll
- **Metrik:** Policies (Richtlinien) — kommerzielle Vereinbarungen, Präferenzen, AS-Pfade
- **Konvergenz:** Absichtlich langsam (Stabilität hat Vorrang)
- **Einsatzbereich:** **Zwischen Autonomous Systems** — das Protokoll, das das Internet zusammenhält

**Funktionsweise:** Jedes AS teilt anderen AS mit, welche IP-Präfixe es verwaltet. BGP wählt Routen nicht nur nach Distanz, sondern nach Geschäftsvereinbarungen und Netzwerkrichtlinien.

**Beispiel aus dem MTR-Test:**
```
Hop 1:  fritz.box           → Lokales Netz
Hop 2:  Deutsche Telekom    → AS3320 (DTAG)
        ↓ BGP-Grenze ↓
Hop 4:  2620:107:4000::     → AS16509 (AWS)
Hop 9:  AWS Zielserver      → Latenz ~9ms
```

**Analogie:** Diplomatische Vereinbarungen zwischen Ländern — nicht nur der kürzeste Weg zählt, sondern auch politische und wirtschaftliche Faktoren.

---

### Vergleichsmatrix: RIP vs. OSPF vs. BGP

| Merkmal | RIP | OSPF | BGP |
|---|---|---|---|
| Protokolltyp | Distanzvektor | Link-State | Pfadvektor |
| Metrik | Hop-Anzahl | Kosten (Bandbreite) | Policies / AS-Pfad |
| Max. Skalierung | 15 Hops | Sehr groß (kein Limit) | Internet-Maßstab |
| Konvergenz | Langsam | Schnell | Absichtlich langsam |
| Einsatzbereich | Kleine Netze (veraltet) | Intra-AS (Unternehmen) | Inter-AS (Internet) |
| Administrative Distanz | 120 | 110 | 20 (eBGP) / 200 (iBGP) |

---

## 4. Gateway vs. Router

### Der Router

Ein Router ist ein Netzwerkgerät, das Pakete zwischen verschiedenen Netzwerken weiterleitet. Er trifft Routing-Entscheidungen anhand der Ziel-IP-Adresse und seiner Routing-Tabelle.

### Das Gateway (Netzwerk-Gateway)

Ein Gateway ist ein **Übergangspunkt zwischen zwei unterschiedlichen Netzwelten**. Es kann zusätzlich zum Routing auch:
- **Protokollübersetzung** durchführen (z.B. zwischen IPv4 und IPv6)
- **NAT** (Network Address Translation) ausführen (private IPs → öffentliche IP)
- Als Sicherheitsinstanz (Firewall) fungieren

### Analogie: Taxi vs. Flughafen

- **Router** = Taxi innerhalb einer Stadt — bewegt Pakete von A nach B im gleichen Netzwerk
- **Gateway** = Flughafen — der obligatorische Ausgangspunkt, um die Stadt (das lokale Netz) zu verlassen und in eine andere Welt (das Internet) zu gelangen

### Praktisches Beispiel: Die Fritzbox

Die Fritzbox zu Hause übernimmt **beide Rollen gleichzeitig**:

```
Internet (WAN)
      │
[Fritzbox 192.168.178.1]  ← Gateway: Ausgang zum Internet
      │                    ← Router: Weiterleitung im LAN
  192.168.178.0/24
   ├── ThinkPad L15 (.144)
   └── Zweiter PC – gikaze (.133)
```

- **Als Router:** Leitet Pakete zwischen lokalen Geräten weiter
- **Als Gateway (Default Gateway):** Alle Pakete mit unbekanntem Ziel werden hierhin gesendet und ins Internet weitergeleitet

### Unterschied in der Praxis

| Merkmal | Router | Gateway |
|---|---|---|
| Hauptaufgabe | Pakete zwischen Netzen weiterleiten | Übergang zwischen unterschiedlichen Netzwelten |
| Position | Kann intern liegen | Immer an der Netzgrenze |
| Protokollübersetzung | Nein | Möglich (z.B. IPv4 ↔ IPv6) |
| Beispiel | Interner Unternehmens-Router | Fritzbox, AWS Internet Gateway |

### AWS-Bezug

In AWS entspricht das **Internet Gateway (IGW)** dem Default Gateway: Ohne IGW in der Route Table können EC2-Instanzen im Public Subnet das Internet nicht erreichen — genau wie ein PC ohne Default Gateway die Fritzbox nicht kennt und somit nicht ins Internet kommt.

---

## 5. Zusammenfassung

```
Dein ThinkPad
      │
[Fritzbox]          → Default Gateway + Router (LAN)
      │                Statisches Routing reicht hier
[Deutsche Telekom]  → AS3320, internes Routing via OSPF
      │                BGP-Grenze zwischen AS
[AWS Frankfurt]     → AS16509, internes Routing via OSPF
      │
[Zielserver]
```

- **Statisches Routing** → kleine, vorhersehbare Netze (Heimnetz, AWS VPC Route Tables)
- **RIP** → veraltet, max. 15 Hops, für Laborzwecke
- **OSPF** → modernes intra-AS Protokoll, basiert auf Bandbreite und Karte
- **BGP** → das Protokoll des Internets, verbindet alle AS weltweit
- **Gateway** = Router + Grenzfunktion + mögliche Protokollübersetzung
