FROM archlinux:latest

# 1. Installation des dépendances système et outils de compilation
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git apache php php-apache php-gd php-intl php-apcu \
    ffmpeg vlc libvlc mariadb net-tools shared-mime-info --needed

# 2. Création d'un utilisateur "builder" (makepkg ne peut pas tourner en root)
RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER builder
WORKDIR /home/builder

# 3. Récupération et compilation de ZoneMinder (via AUR)
# Note : Nous installons aussi une dépendance commune de l'AUR si nécessaire
RUN git clone https://aur.archlinux.org/zoneminder.git && \
    cd zoneminder && \
    makepkg -si --noconfirm

# 4. Retour à l'utilisateur root pour la configuration finale
USER root

# 5. Configuration Apache pour ZoneMinder
RUN cp /etc/zm/apache.conf /etc/httpd/conf/extra/zoneminder.conf && \
    echo "Include conf/extra/zoneminder.conf" >> /etc/httpd/conf/httpd.conf

# Configuration PHP (activation des extensions nécessaires)
RUN sed -i 's/;extension=pdo_mysql/extension=pdo_mysql/' /etc/php/php.ini && \
    sed -i 's/;extension=gd/extension=gd/' /etc/php/php.ini && \
    sed -i 's/;extension=intl/extension=intl/' /etc/php/php.ini

# Optimisation de PHP pour ZoneMinder
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/' /etc/php/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 300/' /etc/php/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php/php.ini && \
    sed -i "s/;date.timezone =/date.timezone = Europe\/Paris/" /etc/php/php.ini

# Activation d'OPcache
RUN echo "zend_extension=opcache" >> /etc/php/php.ini && \
    echo "opcache.enable=1" >> /etc/php/php.ini && \
    echo "opcache.memory_consumption=128" >> /etc/php/php.ini && \
    echo "opcache.interned_strings_buffer=8" >> /etc/php/php.ini && \
    echo "opcache.max_accelerated_files=4000" >> /etc/php/php.ini && \
    echo "opcache.revalidate_freq=60" >> /etc/php/php.ini

# 6. Script de démarrage pour initialiser la DB si vide et lancer Apache
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
