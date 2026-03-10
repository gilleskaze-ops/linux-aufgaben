
## Befehle zum Erstellen von access_log.txt Datei

seq 1 50 | while read i; do IP="192.168.1.$((RANDOM % 20 + 1))"; S=$(shuf -e 200 200 404 404 500 -n1); M=$(shuf -e GET GET POST -n1); B=$([ "$S" = "200" ] && echo $((RANDOM % 2000 + 1000)) || echo 0); F=$([ "$M" = "GET" ] && shuf -e index.html details.html -n1 || shuf -e login.html register.html -n1); echo "$IP - [$(date +'%d/%b/%Y:%H:%M:%S %z')] \"$M/$F HTTP/1.1\" $S $B"; done > access_log.txt


## Befehle zum Erstellen von error_log.txt Datei.
awk '$7 != 200 { print > "error_log.txt" }' access_log.txt


## Befehle zum Erstellen von success_log.txt Datei
awk '$7 == 200 { print > "success_log.txt" }' access_log.txt


## Befehle zum Ermitteln von meist aufgerufenen Funktionen mit Status 200
      
awk '$7 == 200 { print $5 }' access_log.txt | sort | uniq -c | sort -rn | 'sed s/"//g' > top_function_called.txt 


## Befhele zum Hinzufügen von Datum und Anzahl von fehlgeschlagenen Requests
echo -e "############################################################################\n$(date +'%d/%m/%Y %H:%M:%S') \nNumber of failure:  $(wc -l < error_log_backup.txt)" >> error_log.txt 
