FROM tugboatqa/php:8.1-apache

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
RUN apt-get update && apt-get install bash git curl patch libmagickwand-dev libzip-dev zip imagemagick -y

RUN pecl install pcov imagick
RUN docker-php-ext-enable imagick
RUN docker-php-ext-configure gd --with-jpeg
RUN docker-php-ext-install gd bz2 pdo zip

RUN echo 'extension=pcov.so' >> /usr/local/etc/php/php.ini

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN echo 'export PATH=$PATH:$HOME/.composer/vendor/bin'  >> ~/.profile
RUN echo 'export PATH=$HOME/.composer/vendor/bin:$PATH' >> ~/.bashrc

RUN sed -i 's/128M/-1/g' /usr/local/etc/php/php.ini

RUN a2enmod rewrite
RUN echo "\nServerName localhost\n" >> /etc/apache2/apache2.conf
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
RUN sed -i 's/www\/html/www\/localhost\/htdocs/g' /etc/apache2/sites-available/000-default.conf

RUN apache2ctl configtest
RUN apache2ctl restart

RUN composer self-update && \
    composer global config minimum-stability dev && \
    composer global config prefer-stable true && \
    composer global require drush/drush:^8 acquia/blt-launcher
ENV PATH="/root/.composer/vendor/bin:${PATH}"

RUN usermod -a -G root www-data

RUN php -v