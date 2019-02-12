#!/bin/bash

convert=/home/lucas/.local/bin                           #Conserve le chemin d'accès au répertoire de stockage des fichiers csv et html
bureau=/home/lucas/Desktop                               #Conserve le chemin d'accès aux fichiers d erreurs et de test
compteur=0                                               #Initialise une variable de compteur
compteur_visite=0                                        #Initialise une variable de compteur
visites_total=0                                          #Initialie le compteur de visiteurs
visites_ligne=0                                          #Initialise la valeur correspondant au nombre de ligne du fichier IP_origine


cd $convert                                             #On se postionne dans le répertoire de stockage des fichiers du site afin de simplifier les commandes 

#Récupération du nombre de visiteurs#

cat fichiers_csv/fichier_titre_IP.csv > fichiers_csv/IP.csv   #Réinitialise de fichier IP et lui donne un titre
cat fichiers_csv/IP_origine.csv >> fichiers_csv/IP.csv        #Insère dans le fichier IP les données du fichier IP_origine
Nombre_IP=`cat fichiers_csv/IP.csv | wc -l`                   #Récupère le nombre de lignes du fichier IP_origine

while [ $compteur_visite -ne $Nombre_IP ]                     #Boucle permettant de parcourir entièrement le fichier IP_origine
do 
        compteur_visite=$(($compteur_visite+1))               #Incrémentation de variable de compteur permettant de parcourir le fichier un nombre précis de fois correspondant à son nombre de ligne
        visites_total=`awk '{t+=$1} END {print t}' fichiers_csv/IP_origine.csv`  #Affecte à  la variable visites_total le nombre total de visites qui est égal à la somme de tous les nombres de la première colonne du fichier IP_origine

done

echo "nombre de visites total : $visites_total" >> fichiers_csv/IP.csv           #Ajoute la valeur de la variable visites_total dans le fichier IP
echo "nombre de visiteurs : $Nombre_IP" >> fichiers_csv/IP.csv                   #Ajoute la valeur de la variable Nombre_IP dans le fichier IP

#Mise en page

cat fichiers_csv/fichier_titre_serveurs.csv > fichiers_csv/fichier_serveurs_pret.csv      #Ajoute au fichier fichier_serveur_pret un titre
cat fichiers_csv/fichier_serveurs.csv >> fichiers_csv/fichier_serveurs_pret.csv           #Ajoute au fichier fichier_serveur_pret le contenu du fichier fichier_serveur


#Transcription des fichiers .csv en .html#

./csv2html -o fichier_titre_site.html fichiers_csv/fichier_titre_site.csv 2> $bureau/Erreurs.txt       #Copie le fichier fichier_titre_site sous format HTML
./csv2html -o fichier_serveurs.html fichiers_csv/fichier_serveurs_pret.csv 2> $bureau/Erreurs.txt      #Copie le fichier fichier_serveurs_pret au format HTML 
./csv2html -o fichier_adresses.html fichiers_csv/IP.csv 2> $bureau/Erreurs.txt                         #Pareil avec le fichier IP

#Ecriture du fichier contenant les informations du site de supervision  dans le fichier .html#

cat fichier_titre_site.html > fichier_site.html            #Ajoute au fichier_site un titre
cat fichier_adresses.html >> fichier_site.html             #Ajoute au fichier site la liste d'IP
cat fichier_serveurs.html >> fichier_site.html             #Ajoute au fichier site les informations relatives à l'état des serveurs

#Boucle permettant de trier les erreurs afin d'éliminer une erreur non impactante liée au code pyhton#


Nombre_lignes=`cat $bureau/Erreurs.txt | wc -l`            #Compte le nombre de ligne du fichier Erreurs

while [ $compteur -ne $Nombre_lignes ]                     #Permet de parcourir le fichier d'Erreurs
do 
	compteur=$(($compteur+1))                          #Incrémentation de la variable de compteur afin de parcourir le fichier le bon nombre de fois
	if [ "$line" = "Traceback (most recent call last):" ]       #Cherche l'erreut du script python dont on veut se débarasser
	then
	sed $compteur,$(($compteur+16))d $bureau/Erreurs.txt> $bureau/Erreurs_triées.txt    #Supprime l'erreut que l on cherche
	fi
done

#Affichage des erreurs conservées#

cat $bureau/Erreurs_triées.txt

#Test d éxécution du script, cet ajout de ligne de texte dans un fichier permet de vérifier que l éxécution automatique a bien lieu#

echo "Ca fonctionne" >> $bureau/Test



