#!/bin/bash

dstpath=$HOME/projects/scripts
#dstfile=result
dstfile=result_$(date +%Y%m%d_%H%M%S)

# Umgebungsvariablen ausgeben
echo "PWD  : $PWD"
echo "USER : $USER"
echo "HOME : $HOME"

# prüfen ob Ordner vorhanden ist
if [ ! -d "$dstpath" ]; then
	mkdir -p "$dstpath"
	echo "Ordner $dstpath wurde erstellt."
fi


# Systeminfos auslesen

date=$(date)
ipadress=$(hostname -I)

#echo "" > $dstpath/$dstfile
#echo "$date" >> $dstpath/$dstfile
#echo "$ipadress" >> $dstpath/$dstfile

distro=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
#echo "$distro" >> $dstpath/$dstfile

{
   echo "$date"
   echo "$ipadress"
   echo "$distro"
   echo "PWD  : $PWD"
   echo "USER : $USER"
   echo "HOME : $HOME"
} > $dstpath/$dstfile

