FROM gitpod/workspace-mysql

RUN sudo add-apt-repository ppa:ondrej/php && \
    sudo install-packages php8.0

RUN sudo apt-get update && sudo apt-get install -y \
    imagemagick \
    libmagickwand-dev \
    libzip-dev \
    keychain \
    php8.0-gd \
    php8.0-xml \
    php8.0-curl \
    php8.0-zip \
    php8.0-bz2 \
    php8.0-imagick \
    php8.0-mysql \
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

RUN a2dismod php7.4 && a2enmod php8.0