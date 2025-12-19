#!/bin/bash

# Attendre que la DB soit accessible
echo "En attente de MariaDB sur $ZM_DB_HOST..."
while ! mysqladmin ping -h"$ZM_DB_HOST" --silent; do
    sleep 1
done

# Initialiser la base de données si elle est vide
if ! mysql -h"$ZM_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "use zm; show tables;" | grep -q "Config"; then
    echo "Initialisation de la base de données ZoneMinder..."
    mysql -h"$ZM_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" zm < /usr/share/zoneminder/db/zm_create.sql
fi

# Lancer Apache en arrière-plan et le daemon ZoneMinder
/usr/bin/zmpkg.pl start
/usr/bin/httpd -D FOREGROUND
