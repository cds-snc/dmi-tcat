FROM fedora:24
MAINTAINER Dave Samojlenko <dave.samojlenko@tbs-sct.gc.ca>

RUN dnf install -v -y --refresh \
 *mbstring nginx httpd-tools php-fpm php-curl php-readline php-mcrypt php-mysql php-apcu php-cli \
 wget sqlite tar git sqlite-devel curl supervisor cronie php-pgsql php-pdo php-gd geos-php geos \
 && dnf clean all && rm -rf /usr/share/doc /usr/share/man /tmp/*

COPY docker/supervisord.conf /etc/supervisord.d/dmi-tcat.ini
COPY docker/php-fpm.conf /etc/php-fpm.conf
COPY docker/crontab /etc/crontab

# Copy the various nginx and supervisor conf (to handle both fpm and nginx)
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
    echo "daemon off;" >> /etc/nginx/nginx.conf && \
    rm -rf /etc/nginx/default.d && \
    rm -f /etc/nginx/conf.d/*

# Install dmi-tcat
RUN git clone https://github.com/digitalmethodsinitiative/dmi-tcat.git /var/www/dmi-tcat \
 && cp /var/www/dmi-tcat/config.php.example /var/www/dmi-tcat/config.php \
 && chown -R nginx /var/www \
 && cd /var/www/dmi-tcat \
 && mkdir analysis/cache logs proc \
 && chown nginx:nginx analysis/cache \
 && chmod 755 analysis/cache \
 && chown nginx logs proc \
 && chmod 755 logs proc \
 && chmod 644 /etc/crontab \
 && sed -i 's/http://g' capture/index.php

WORKDIR /var/www/dmi-tcat
COPY docker/nginx-site.conf /etc/nginx/conf.d/default.conf
COPY docker/entrypoint.sh /sbin/entrypoint.sh

EXPOSE 8000

CMD ["/sbin/entrypoint.sh"]
