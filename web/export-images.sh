#!/bin/bash

# --- Configuration ---
BACKUP_DIR="./backups/$(date +%Y-%m-%d_%H-%M)"
DB_CONTAINER="zm-db"
WEB_CONTAINER="zm-web"
MYSQL_USER="zmuser"
MYSQL_PASSWORD="zmpassword"
DATABASE="zm"

mkdir -p "$BACKUP_DIR"

echo "--- Début de l'exportation ZoneMinder ---"

# 1. Exportation de la base de données
echo "[1/3] Sauvegarde de la base de données SQL..."
docker exec $DB_CONTAINER mysqldump -u$MYSQL_USER -p$MYSQL_PASSWORD $DATABASE > "$BACKUP_DIR/zm_database.sql"

# 2. Exportation des événements (Vidéos/Images)
# On utilise tar directement via docker cp pour ne pas arrêter le conteneur
echo "[2/3] Exportation des fichiers médias (Events)..."
docker cp $WEB_CONTAINER:/var/lib/zoneminder/events "$BACKUP_DIR/events_raw"

# 3. Compression du tout (Optionnel mais recommandé)
echo "[3/3] Compression de l'archive finale..."
tar -czf "${BACKUP_DIR}.tar.gz" -C "$BACKUP_DIR" .
rm -rf "$BACKUP_DIR" # Supprime le dossier non compressé

echo "--- Exportation terminée ! Fichier : ${BACKUP_DIR}.tar.gz ---"
