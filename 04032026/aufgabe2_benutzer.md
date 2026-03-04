# Aufgabe 2: Benutzerverwaltung in Linux

## root vs. normale Benutzer
Der 'root'-Benutzer ist der Administrator mit uneingeschränkten Rechten. Er darf alles im System verändern. Ein normaler Benutzer hat nur Zugriff auf seine eigenen Dateien.

## Warum ist root gefährlich?
Wenn man immer als root arbeitet, kann ein kleiner Tippfehler (wie ein falsches Leerzeichen beim Löschen) das ganze System zerstören. Deshalb nutzt man im Alltag einen normalen User und holt sich Admin-Rechte nur kurzzeitig mit dem Befehl 'sudo'.

## Dateien /etc/passwd und /etc/group
- In /etc/passwd stehen die Benutzerkonten (Name, ID, Home-Verzeichnis).
- In /etc/group stehen die Gruppen und wer Mitglied ist. 
Beide Dateien sind mit Doppelpunkten (:) strukturiert.


## Benutzer entfernen
Ich habe hier 'deluser --remove-home' verwendet. Alternativ hätte man auch 'userdel -r' nutzen können, um das Home-Verzeichnis direkt mitzulöschen.
