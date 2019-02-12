#!/bin/bash
IP_HTTP=127.0.0.1
DOMAIN=google.com
IPDOMAIN=216.58.215.46
HTTP_FILE=index.html
URL=http://google.com
ADDR_ADMIN=vincent.vie@viacesi.fr
USER_HTTP=taikylah@192.168.159.138:/home/taikylah/Documents/

#redirection des erreurs de la suppression des fichier temporaires qui peuvent ne pas exister pour ne pas les afficher ni aux admins ni aux Users
rm fichier_serveurs.csv 2>/dev/null
touch fichier_serveurs.csv

rm ERROR.txt 2>/dev/null
touch ERROR.txt

#ping puis selection du 4eme bloc apres un = puis selection de la 2eme ligne uniquement pour supprimer le superflux d'info de la commande ping.
ping="`ping -c1 "$IP_HTTP" | cut -d"=" -f4 | sed -n '2p'`"

if [ -z "$ping" ]
then
	echo "Serveur innaccessible" >> ERROR.txt
	echo "Serveur innaccessible" >> fichier_serveurs.csv
else
	echo "Ping en $ping" > fichier_serveurs.csv
fi

#verification de la resolution de nom du site web
titi="`nslookup $DOMAIN | sed -n '6p'  | cut -d" " -f2`"
if [ "$titi" = "$IPDOMAIN" ]
then 
	echo "Le DNS Fonctionne" >> fichier_serveurs.csv
else
	echo "Erreur de DNS" >> ERROR.txt
	echo "Erreur de DNS" >> fichier_serveurs.csv
fi

#Verification de l'existence du site web
wget $URL 2>WGET_TMP.tmp

if [ -f $HTTP_FILE ]
then 
	echo "Site web existant" >> fichier_serveurs.csv
	rm $HTTP_FILE

	#recup temps de connection page web
	temps_co_web="`cat WGET_TMP.tmp | sed -n '13p' | cut -d"=" -f2 `"
	echo "Connection au site en $temps_co_web" >> fichier_serveurs.csv
	rm WGET_TMP.tmp
else
	echo "Erreur site web inaccessible" >> ERROR.txt
	echo "Erreur site web inaccessible" >> fichier_serveurs.csv
fi

#envoi du fichier log.csv sur le serveur HTTP
sshpass -p "Password" scp fichier_serveurs.csv "$USER_HTTP"

#envoi d'un mail contenant les erreurs si il y en a
if [ -s ERROR.txt ]
then
	echo "Ci-join le fichier ERROR.txt" | mail -s "ERROR" -A ERROR.txt $ADDR_ADMIN
fi



