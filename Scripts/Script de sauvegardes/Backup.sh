#!/bin/bash

#Utilisation de la commande 'crontab -e' pour plannifier automatiquement le lancement du script tout les jours à 00h

#Déclaration des variables
APACHE_CONF=/etc/apache2
WWW_CONF=/var/www

LOG_FILE=/var/run/backup/log.txt
USER_MAIL=root

DATE="`date +'%d-%m-%y'`"
BACKUP=/var/run/backup

#Vérification de la modification du dossier dans les dernières 24h | 0 = non modifier, 1 = modifier
FILE_MODIFY_APACHE=`find $APACHE_CONF -type f -mtime -1 2>/dev/null | wc -l`
FILE_MODIFY_WWW=`find $WWW_CONF -type f -mtime -1 2>/dev/null | wc -l`

#Déclaration de ma fonction en cas d'erreur de sauvegarde
erreur_backup ()
{	
	#Vérification de l'existence de l'archive dans le cas contraire on envoie un message d'erreur à l'administrateur
	if [ ! -e $BACKUP/Backup_inc_$DATE.tgz ] && [ $FILE_MODIFY_APACHE -eq 1 ] || [ $FILE_MODIFY_WWW -eq 1 ]
	then
		echo "Erreur de sauvegarde du $DATE !" | mail -s "Erreur Backup!" $USER_MAIL
		echo -e "--- ERREUR DE BACKUP du $DATE A `date +%H:%M:%S` ---\n" >> $LOG_FILE
	fi
}

#Déclaration de ma fonction pour vérifier l'espace disque disponible
espace_disque ()
{
	#Récupération du pourcentage de disque utilisé
	ESPACE=`df -h / | sed -n 2p | cut -c40-41`

	#Envoi d'un mail à l'administrateur en cas de manque d'espace de disque
	if [ $ESPACE -ge 90 ]
	then
		echo "Manque de stockage le $DATE !" | mail -s "Stockage!" $USER_MAIL
		echo -e "--- MANQUE DE STOCKAGE LE $DATE A `date +%H:%M:%S` ---\n--- STOCKAGE A $ESPACE % LE $DATE A `date +%H:%M:%S` ---\n" >> $LOG_FILE
		exit 0
	else
		echo -e "--- STOCKAGE A $ESPACE % LE $DATE A `date +%H:%M:%S` ---\n" >> $LOG_FILE
	fi
}

#Déclaration de ma fonction pour supprimer les vieilles sauvegardes
backup_time ()
{
	#Calcul du nombre de sauvegarde incrémentale disponible
	NBR_BACKUP_INC=`ls -lt $BACKUP | grep Backup | grep inc | wc -l`

	#Vérification du nombre de sauvegarde, s'il dépasse 183 environ 6 mois on supprime la plus vieille sauvegardée
	if (( $NBR_BACKUP_INC >= 183 ))
	then
		`cd $BACKUP ; rm -f $(ls -1t | tail -1)`
	fi
}

#Déclaration de ma fonction de sauvegarde complète
save_complete ()
{
	if [ -e $BACKUP ]
	then
		#Création d'une archive avec le dossier de configuration apache2 et www
		tar -czf $BACKUP/Backup_comp_$DATE.tgz $APACHE_CONF $WWW_CONF 2>/dev/null
	else
		mkdir "$BACKUP"
		tar -czf $BACKUP/Backup_comp_$DATE.tgz $APACHE_CONF $WWW_CONF 2>/dev/null
	fi
	echo -e "--- BACKUP COMPLETE DU $DATE A `date +%H:%M:%S` ---\n" >> $LOG_FILE
}

#Déclaration de ma fonction de sauvegarde incrémentale
save_incrementale ()
{	
	#Faire une sauvegarde incrémentale en cas de modification des fichiers dans les dernières 24h
	if [ $FILE_MODIFY_APACHE -eq 0 ] && [ $FILE_MODIFY_WWW -eq 0 ]
	then
		echo -e "--- PAS DE MODIFICATION, DONC PAS DE SAUVEGARDE ---\n" >> $LOG_FILE
		exit 0
	else
		if [ ! $FILE_MODIFY_APACHE -eq 0 ] && [ ! $FILE_MODIFY_WWW -eq 0 ]
		then
			tar -czf $BACKUP/Backup_inc_$DATE.tgz `find $APACHE_CONF $WWW_CONF -type f -mtime -1` 2>/dev/null
		else
			if [ $FILE_MODIFY_APACHE -eq 0 ]
			then
				tar -czf $BACKUP/Backup_inc_$DATE.tgz `find $WWW_CONF -type f -mtime -1` 2>/dev/null
			else
				tar -czf $BACKUP/Backup_inc_$DATE.tgz `find $APACHE_CONF -type f -mtime -1` 2>/dev/null
			fi
		fi
		echo -e "--- BACKUP INCREMENTALE DU $DATE A `date +%H:%M:%S` ---\n" >> $LOG_FILE
	fi
}

#Appel des fonctions déclarées
espace_disque
backup_time

#Calcul du nombre de sauvegarde complète disponible
NBR_BACKUP_COMP=`ls $BACKUP/Backup_comp_* 2>/dev/null | wc -l`

if [ $NBR_BACKUP_COMP -gt 0 ]
then
	save_incrementale
	erreur_backup
else
	save_complete
	erreur_backup
fi

exit 0