FROM ubuntu:14.04
MAINTAINER sergey@falinsky.com

RUN apt-get update
RUN apt-get install -y \
	vim \
	curl \
	ngrok-client \
	apache2 \
	php5 \
	php5-cli \
	libapache2-mod-php5 \
	php5-intl \
	php5-gd \
	php5-curl \
	php5-mysql \
	php5-xdebug

RUN apt-get clean \
 	&& rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

#### config php

RUN sed -i '$ a\xdebug.var_display_max_depth=4' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.max_nesting_level=500' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.var_display_max_data=-1' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.remote_enable=1' /etc/php5/mods-available/xdebug.ini
RUN sed -i '$ a\xdebug.remote_port="9000"' /etc/php5/mods-available/xdebug.ini

RUN sed -i '$ a\opcache.max_accelerated_files=20000' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.interned_strings_buffer=8' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.memory_consumption=384' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.revalidate_freq=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.validate_timestamps=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.fast_shutdown=1' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.enable_cli=0' /etc/php5/mods-available/opcache.ini
RUN sed -i '$ a\opcache.enable=1' /etc/php5/mods-available/opcache.ini

RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 512M/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/apache2/php.ini
RUN sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/apache2/php.ini

RUN sed -ri 's/^display_errors\s*=\s*Off/display_errors = On/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^;date.timezone\s*=/date.timezone = UTC/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^memory_limit\s*=\s*128M/memory_limit = 512M/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^post_max_size\s*=\s*8M/post_max_size = 2048M/g' /etc/php5/cli/php.ini
RUN sed -ri 's/^upload_max_filesize\s*=\s*2M/upload_max_filesize = 2048M/g' /etc/php5/cli/php.ini

#### config apache

RUN a2enmod rewrite ssl headers
RUN mkdir /etc/apache2/ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/app.key -out /etc/apache2/ssl/app.crt -subj /C=US/ST=New\ York/L=New\ York\ City/O=SuperDeveloper/OU=Developers/CN=localhost

RUN a2dissite 000-default
COPY app_vhost.conf /etc/apache2/sites-available/
COPY app_vhost_ssl.conf /etc/apache2/sites-available/
RUN a2ensite app_vhost app_vhost_ssl

EXPOSE 80 443

RUN mkdir -p /home/webapp/htdocs/web/
COPY index.php /home/webapp/htdocs/web/

RUN mkdir -p /home/webapp/htdocs/app/cache
RUN chown www-data:www-data /home/webapp/htdocs/app/cache
VOLUME /home/webapp/htdocs/app/cache

RUN mkdir /home/webapp/htdocs/app/logs
RUN chown www-data:www-data /home/webapp/htdocs/app/logs
VOLUME /home/webapp/htdocs/app/logs

COPY app_start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/app_start.sh


CMD ["/usr/local/bin/app_start.sh"]

