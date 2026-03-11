# Aufgabe: SSH & Paketverwaltung
**Datum:** 05.03.2026  
**System:** Ubuntu 24.04.4 LTS (ThinkPad DCI) + Ubuntu 22.04.5 LTS (Remote-PC)  
**Benutzer:** dci-student

---

## Teil 1 — Paketverwaltung mit `apt`

### 1.1 System identifizieren

```bash
cat /etc/os-release
which apt
```

**Output:**
```
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
ID=ubuntu
ID_LIKE=debian
/usr/bin/apt
```

→ Debian-basiertes System, Paketmanager: `apt`

---

### 1.2 Paket suchen und Informationen abrufen

```bash
apt search htop
apt show htop
```

**Output (Auszug):**
```
htop/noble,now 3.3.0-4build1 amd64  [installiert]
  Interaktiver Prozessbetrachter

Package: htop
Version: 3.3.0-4build1
Installed-Size: 434 kB
Depends: libc6 (>= 2.38), libncursesw6 (>= 6), libnl-3-200, libnl-genl-3-200
Homepage: https://htop.dev/
```

→ `htop` war bereits installiert. Alternativpaket `sl` für die Installation verwendet.

---

### 1.3 Paket installieren

```bash
sudo apt install sl
sl
```

→ `sl` (Steam Locomotive) erfolgreich installiert. Beim Ausführen von `sl` erscheint eine animierte Dampflokomotive im Terminal — ein klassischer Unix-Scherz für Tippfehler (`sl` statt `ls`).

---

### 1.4 System aktualisieren

```bash
sudo apt update
sudo apt upgrade
```

→ Paketlisten aktualisiert, alle installierten Pakete auf die neueste Version gebracht.

---

### 1.5 Paket entfernen

```bash
sudo apt remove sl
sudo apt autoremove
```

→ `sl` vollständig deinstalliert, nicht mehr benötigte Abhängigkeiten entfernt.

---

## Teil 2 — SSH: Verbindung zu einem entfernten System

### 2.1 SSH-Server auf dem Remote-PC installieren

Auf dem Remote-PC (Ubuntu 22.04):

```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl status ssh
```

**Hinweis:** `sudo apt install` war zunächst blockiert. Mit folgenden Befehlen wurde der Grund identifiziert:

```bash
ps aux | grep unattended
sudo lsof /var/lib/dpkg/lock-frontend
```

→ `unattended-upgrades` (PID 9917) hielt die dpkg-Sperre. Das System führte automatische Sicherheitsupdates im Hintergrund durch. Dies ist normales Verhalten — `dpkg` verwendet einen **exklusiven Lock (Mutex)**, um gleichzeitige Schreibvorgänge und damit Systemkorruption zu verhindern. Nach Abschluss des Prozesses war die Installation möglich.

→ SSH-Dienst aktiv: `active (running)`

---

### 2.2 Erste SSH-Verbindung (passwortbasiert)

Vom ThinkPad DCI:

```bash
ssh gikaze@192.168.178.133
```

**Output (Auszug):**
```
The authenticity of host '192.168.178.133' can't be established.
ED25519 key fingerprint is SHA256:yECuwG+bVA1QuvKeGXg2/oU/NcPIbFo8COdzmLNXAhk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.178.133' (ED25519) to the list of known hosts.
gikaze@192.168.178.133's password:
```

→ Verbindung erfolgreich. Beim ersten Verbindungsaufbau wird der Host-Fingerprint in `~/.ssh/known_hosts` gespeichert.

Ausgeführte Befehle auf dem Remote-System:

```bash
hostname   # → ubuntu
pwd        # → /home/gikaze
whoami     # → gikaze
ls -la
```

---

### 2.3 SSH mit Verbose-Modus (`-v`)

```bash
ssh -v gikaze@192.168.178.133
```

**Wichtige Erkenntnisse aus dem Output:**

```
kex: algorithm: sntrup761x25519-sha512
kex: client->server cipher: chacha20-poly1305
```
→ Aushandlung des Verschlüsselungsalgorithmus zwischen Client und Server.

```
Next authentication method: publickey
Offering public key: /home/dci-student/.ssh/id_ed25519
Authentications that can continue: publickey,password
```
→ SSH versucht zuerst die Schlüssel-Authentifizierung. Da der öffentliche Schlüssel noch nicht auf dem Remote-System hinterlegt war, fiel es auf Passwort-Authentifizierung zurück.

```
Authenticated to 192.168.178.133 using "password".
```

---

## Teil 3 — SSH-Keys: Schlüsselbasierte Authentifizierung

### 3.1 Vorhandene Schlüssel prüfen

```bash
ls -la ~/.ssh/
```

→ Schlüsselpaar `id_ed25519` / `id_ed25519.pub` bereits vorhanden (aus früherer Konfiguration). Kein neues Schlüsselpaar nötig.

**Hinweis zur Schlüsselerzeugung:**  
Ein neues Schlüsselpaar wird mit folgendem Befehl erstellt:
```bash
ssh-keygen -t ed25519 -C "dci-student@ThinkPad-L15"
```
- `-t ed25519` → Algorithmus (modern, empfohlen)
- `-C` → Kommentar zur Identifikation des Schlüssels

---

### 3.2 Öffentlichen Schlüssel auf den Remote-PC kopieren

```bash
ssh-copy-id gikaze@192.168.178.133
```

**Output:**
```
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed
gikaze@192.168.178.133's password:
Number of key(s) added: 1
Now try logging into the machine, with: "ssh 'gikaze@192.168.178.133'"
```

→ Der öffentliche Schlüssel wurde automatisch in `~/.ssh/authorized_keys` auf dem Remote-PC eingetragen.

---

### 3.3 Verbindung ohne Passwort testen

```bash
ssh gikaze@192.168.178.133
```

→ Verbindung erfolgreich **ohne Passwortabfrage**. SSH hat den privaten Schlüssel (`id_ed25519`) automatisch verwendet.

---

### 3.4 Dateiberechtigungen prüfen

Auf dem Remote-PC:

```bash
ls -la ~/.ssh/
```

**Output:**
```
drwx------  2 gikaze gikaze 4096  .           → 700 ✓
-rw-------  1 gikaze gikaze  109  authorized_keys  → 600 ✓
-rw-------  1 gikaze gikaze  464  id_ed25519       → 600 ✓
-rw-r--r--  1 gikaze gikaze  104  id_ed25519.pub   → 644 ✓
```

→ Alle Berechtigungen korrekt. SSH verweigert die Verbindung, wenn Schlüsseldateien zu offen sind.

---

## Zusammenfassung

| Aufgabe | Befehl | Status |
|---|---|---|
| System identifizieren | `cat /etc/os-release` | ✅ |
| Paket suchen | `apt search htop` | ✅ |
| Paket installieren | `sudo apt install sl` | ✅ |
| System aktualisieren | `sudo apt update && upgrade` | ✅ |
| Paket entfernen | `sudo apt remove sl` | ✅ |
| SSH-Server installieren | `sudo apt install openssh-server` | ✅ |
| SSH-Verbindung (Passwort) | `ssh gikaze@192.168.178.133` | ✅ |
| SSH Verbose-Modus | `ssh -v gikaze@192.168.178.133` | ✅ |
| Schlüssel kopieren | `ssh-copy-id gikaze@192.168.178.133` | ✅ |
| SSH ohne Passwort | `ssh gikaze@192.168.178.133` | ✅ |
| Berechtigungen prüfen | `chmod 700 ~/.ssh && chmod 600` | ✅ |
