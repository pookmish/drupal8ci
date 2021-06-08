FROM juampynr/drupal8ci:latest

RUN pecl install pcov
RUN docker-php-ext-enable pcov
RUN docker-php-ext-install bz2
RUN docker-php-ext-install calendar

# Disable xdebug in favor of pcov.
# For the testing package run:
# composer require pcov/clobber --dev
# vendor/bin/pcov clobber
RUN mkdir /usr/local/etc/php/conf.d/disabled
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/disabled/

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/.*?$!/var/www/html/docroot!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html/web!/var/www/html/docroot!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN adduser www-data root
RUN adduser root www-data

# We need to install github/hub to instantiate pull requests automatically.
RUN curl -L https://github.com/github/hub/releases/download/v2.14.1/hub-linux-amd64-2.14.1.tgz \
    | tar -xz \
    && mv hub-linux-amd64-2.14.1/bin/hub /usr/local/bin/ \
    && sudo chmod +x /usr/local/bin/hub \
    && rm -rf hub-linux-amd64-2.14.1/

RUN composer remove hirak/prestissimo
RUN composer self-update --2
RUN composer global config minimum-stability dev
RUN composer global update
RUN cd /var/www && rm -rf html
