# linux_administration
scripts for linux administration

Dieses Skript stellt umfangreiche Tools zur Linux Administration, Automatisierung und Standardisierung zur  
Verfügung die auf einem, mehreren oder allen Servern ausgeführt werden können.

Das Skript muss auf die jeweilen Bedürfnisse angepasst werden.

Die Paket Administration richtet sich auf Debian basierte Systeme aus. Die automatischden Updates richten sich auf Ubuntu aus.
Die anderen Funktionen können bei jedem Linux System ausgeführt werden.

Zuerst wählt man die Server Gruppe aus oder trägt einen oder mehrere Server manuell ein.

Beim
rueck_kanal_servername1_servername2
Wird ein Rückkanal aufgebaut so dass diese Server upgedatet werden die keine Verbindung zum Internet haben. Diese Server müssen entprechend konfiguriert werden.
Bei userName Zugang, aktivieren oder deaktiviern, group_2 Dienste neustarten muss man sich bei Bedarf den Code anpassen.


Im zweiten Menü können eine oder mehrere Aktionen für die Servergruppe durchgeführt werden:
	
Es können mehrere Aktionen ausgewählt werden. Es kann aber sein das bei einer mehrfach Auswahl nicht alles durchgeführt wurde. Von daher bitte prüfen und ggf. Aktionen einzelnen ausführen.


ssh_: 
Hier wird nacheinander zu allen Servern in der Liste eine ssh Verbindung aufgebaut. Mit dem Befehl exit wird wird die aktuelle verbindng beendet und nächste Verbindung zum Server auf der Liste aufgebaut.

command:
Bei allen Servern aus der Liste wird ein Kommando ausgeführt dass man manuell eingeben muss.

dateitransfer_zu_remote_servers: 
Datentransfer vov lokal zu einem oder mehreren Servern.

dateitransfer_von_remote_server:
Datentransfer vom remote Server zu lokal.

unhold__onlyhold_icinga:
Bei allen Ubuntu und Debian Servern aus der Liste werden die Pakte die auf hold gesetzt sind auf unhold gesetzt. Nur die Icinga Pakte bleiben auf hold.

update_ :
Bei allen Ubuntu und Debian Servern aus der Liste werden die Paket quellen aktualisiert und die Pakete upgedatet.

hOld:
Bei allen Ubuntu und Debian Servern aus der Liste werden die entsprechenden Pakte auf hold gesetzt.
 
info:
Zu allen Servern aus der Liste werden Infos angezeigt

reboot_ :
Bei allen Servern aus der Liste wird ein reboot durchgeführt.

ssh_key:
Hier wird gezeigt wie die ssh key s erstellt werden.
Bei allen Servern aus der Liste wird ssh public key den man mit pfad angeben muss, integrieret.

basic_config:
Bei allen Servern aus der Liste wird:
  - der multipathd Server disabled und gestoppt
	- automatische Update konfiguriert
	- die entsprechenden Pakte werden auf hold gesetzt
	- die Zeit und Zeitzone wird auf Deutschland gesetzt und es wird die Verbindung zu unserem NTP Server konfiguriert
	- die Paket quellen aktualisiert und die Pakete upgedatet
	- die Command History aktiviert

icinga_installation:
Im Icinga Director muss der Host angelegt und das Kickstartskript muss herunter geladen werden und in den Skriptordner kopiert werden. Der Anfang des Dateiname muss angepasst werden in dem mit Kleinbuchstaben der Hostname hinzugefügt wird.  Dann wird Icinga auf den Servern in der Liste installiert und mit dem Icinga Server verbunden. Damit alle check Skripte auf den Server gelangen muss auch die git_integration durchgeführt werden.

git_integration:
Alle Server aus der Liste werden zum icinga plugin repository (darin sind die Icinga checks) und zum scripts repository  (darin sind general scripts, kubernetes scripts, linux scripts und auch das admin script) hinzugefügt.

 root_email_versand_20.04
 root_email_versand_22.04
Installation und Konfiguration für den Rootmail Versand an linux_root_messages@tltges.local.

syslog_server_integration: 
Alle Server aus der Liste werden in den syslog Server integriert.

abfrage_liste:
Alle Server werden geprüft ob ein reboot aussteht und welche Updates zur Verfügung stehen aber noch nicht installiert sind.

Alle Aktionen werden in einem eigenen Log geloggt.
 
Hier ein Beispiel für einen Anwendungsfall, wenn man mit Admin Tool bei allen Servern multipathd ausschalten möchte:

Bei welche Server auswählen:     all
Dann auswählen:                  command
Dann dieses Kommando einfügen:   systemctl mask multipathd && systemctl stop multipathd
 
Mit OK bestätigen, dann wird nacheinander auf allen Servern das Kommando ausgeführt und eine Ausgabe angezeigt:
 
...
 
server1
systemctl mask multipathd
Created symlink /etc/systemd/system/multipathd.service → /dev/null.
 
server2
systemctl mask multipathd
Created symlink /etc/systemd/system/multipathd.service → /dev/null.
 
server3
systemctl mask multipathd
Created symlink /etc/systemd/system/multipathd.service → /dev/null.
