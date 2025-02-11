FROM gitpod/workspace-mysql

RUN sudo apt-get update && sudo apt-get install -y \
    imagemagick \
    libmagickwand-dev \
    libzip-dev \
    keychain \
    php8.3-curl \
    php8.3-gd \
    php8.3-bz2 \
    php8.3-imagick \
    php8.3.xml \
    php8.3.mbstring \
    php8.3-zip \
    php8.3-mysql \
    php-pear \
    rsync \
    zip
RUN sudo pecl install pcov

ENV APACHE_DOCROOT_IN_REPO=docroot

RUN sudo curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php && \
    sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN sudo chown gitpod:gitpod -R /home/gitpod/.config
RUN composer global config minimum-stability dev && \
    composer global config prefer-stable true && \
    composer global require drush/drush:^8.0 acquia/blt-launcher:^1.0

ENV PATH="/home/gitpod/.config/composer/vendor/bin:${PATH}"
RUN echo 'export PATH=~/.config/composer/vendor/bin:$PATH' >> ~/.bashrc

USER root
RUN echo 'keychain id_rsa' >> /etc/bash.bashrc
RUN echo '. ~/.keychain/`uname -n` -sh' >> /etc/bash.bashrc

RUN mkdir -p /home/gitpod/.ssh
COPY ssh_config /home/gitpod/.ssh/config

RUN sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/g' /etc/php/8.3/apache2/php.ini
RUN sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/8.3/apache2/php.ini
RUN sed -i 's/post_max_size = 8M/post_max_size = 100M/g' /etc/php/8.3/apache2/php.ini
