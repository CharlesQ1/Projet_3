#!/bin/bash
FILE_PATH=/home/taikylah/Documents/toto.log
FINAL_LOG_PATH=/home/taikylah/Documents/IP_origin.csv

#suppression des fichiers requis pour etre sur d'éviter des erreurs
rm tmp 2>/dev/null
rm IP_origin.csv 2>/dev/null

#création des fichiers requis
touch tmp 
touch IP_origin.csv

#lecture puis analyse du fichier access.log
while read ip trash1 trash2 time trash3

#récupération des parties qui nous interessent
do line="$ip $trash1 $trash2 $time $trash3"

#verification de l'heure des connections
timecut="10#$(cut -d: -f2 <<< "$time")"
#si $timecut commence par un 0
if [ $timecut = [[^0]\w] ]
then
	timecut="$(cut -d0 -f2 <<< "$timecut")"
fi
let timecut=$timecut+1

#récupération de l'heure acutelle
heure=$(date +"%H")

#comparaison pour savoir si les connection ont bien été éfféctués dans la dernière heure
if [ $timecut -ge $heure ]
then	
	echo $ip >> tmp
fi
done < $FILE_PATH

#tris puis comptage des occurences d'ip contenues dans le fichier temporaire
sort tmp | uniq -c >> $FINAL_LOG_PATH

#suppressions des logs et des fichiers temporaires
rm $FILE_PATH
rm tmp
