FROM php:8.2-apache

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

RUN rm /etc/apt/preferences.d/no-debian-php
RUN apt update && apt install wget bash git curl patch libmagickwand-dev libzip-dev zip imagemagick rsync default-mysql-client gh freetype* -y && apt upgrade -y

RUN pecl install pcov imagick
RUN docker-php-ext-enable imagick
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install gd bz2 pdo zip pdo pdo_mysql mysqli calendar

RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php &&\
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN composer global config minimum-stability dev &&\
    composer global config prefer-stable true &&\
    composer global require drush/drush:^8 acquia/blt-launcher

ENV PATH "$PATH:/root/.config/composer/vendor/bin"

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN echo 'extension=pcov.so' >> /usr/local/etc/php/php.ini

RUN a2enmod rewrite
RUN echo "\nServerName localhost\n" >> /etc/apache2/apache2.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN sed -i 's/www\/html/www\/html\/docroot/g' /etc/apache2/sites-available/000-default.conf
RUN apache2ctl restart

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt update && apt install gh

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

RUN sed -i 's/128M/-1/g' /usr/local/etc/php/php.ini
RUN usermod -a -G root www-data

RUN sed -i 's/E_ALL/E_ALL \& ~E_DEPRECATED \& ~E_STRICT/g' /usr/local/etc/php/php.ini

RUN mkdir -p ~/.ssh
COPY ssh_config ~/.ssh/config

RUN rm -rf /var/www/html

RUN mkdir /usr/local/nvm
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 18.10.0

# Install nvm with node and npm
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.30.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install 20

ENV NODE_PATH $NVM_DIR/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:${PATH}

RUN composer --version && drush --version
