FROM juampynr/drupal8ci:latest

RUN pecl install pcov
RUN docker-php-ext-enable pcov
RUN docker-php-ext-install bz2
RUN docker-php-ext-install calendar

# Disable xdebug in favor of pcov
RUN mkdir /usr/local/etc/php/conf.d/disabled
RUN mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/disabled/

# Change docroot since we use Composer Drupal project.
RUN sed -ri -e 's!/var/www/html/web!/var/www/html/docroot!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html/web!/var/www/html/docroot!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN adduser www-data root
RUN adduser root www-data

RUN composer global config minimum-stability dev

