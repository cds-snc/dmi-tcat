#!/bin/bash
set -ex

## ENV 

ADMIN_USER=${ADMIN_USER:-admin}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-changeme}
USER=${USER:-demo}
USER_PASSWORD=${USER_PASSWORD:-demo}

SERVERNAME=${SERVERNAME:-localhost}

DB_HOST=${DB_HOST:-mysql}
DB_DATABASE=${DB_DATABASE:-twittercapture}
DB_USERNAME=${DB_USERNAME:-tcat}
DB_PASSWORD=${DB_PASSWORD:-tcat}

# Configure TCAT

sed -i "s/define('ADMIN_USER', 'admin');/define('ADMIN_USER', '$ADMIN_USER');/g" /var/www/dmi-tcat/config.php
sed -i "s/define('CAPTUREROLES', serialize(array('track')));/define('CAPTUREROLES', serialize(array('follow')));/g" /var/www/dmi-tcat/config.php
htpasswd -b -c /etc/nginx/.htpasswd $ADMIN_USER $ADMIN_PASSWORD
htpasswd -b /etc/nginx/.htpasswd $USER $USER_PASSWORD

sed -i "s/^\$twitter_consumer_key = \"\";/\$twitter_consumer_key = \"$CONSUMERKEY\";/g" /var/www/dmi-tcat/config.php
sed -i "s/^\$twitter_consumer_secret = \"\";/\$twitter_consumer_secret = \"$CONSUMERSECRET\";/g" /var/www/dmi-tcat/config.php
sed -i "s/^\$twitter_user_token = \"\";/\$twitter_user_token = \"$USERTOKEN\";/g" /var/www/dmi-tcat/config.php
sed -i "s/^\$twitter_user_secret = \"\";/\$twitter_user_secret = \"$USERSECRET\";/g" /var/www/dmi-tcat/config.php

sed -i "s/dbuser = \"\"/dbuser = \"$DB_USERNAME\"/g" /var/www/dmi-tcat/config.php
sed -i "s/dbpass = \"\"/dbpass = \"$DB_PASSWORD\"/g" /var/www/dmi-tcat/config.php
sed -i "s/database = \"twittercapture\"/database = \"$DB_DATABASE\"/g" /var/www/dmi-tcat/config.php
sed -i "s/hostname = \"localhost\"/hostname = \"$DB_HOST\"/g" /var/www/dmi-tcat/config.php
sed -i "s/example.com\/dmi-tcat\//$SERVERNAME\//g" /var/www/dmi-tcat/config.php

echo "Starting supervisord ..."

echo "Please visit your new TCAT installation at: http://$SERVERNAME/capture/"
echo "Log in using your web-frontend admnistrator credentials."
echo ""
echo "The following steps are recommended, but not mandatory"
echo ""
echo " * Set-up your systems e-mail (sendmail)"
echo ""

exec /usr/bin/supervisord -n -c /etc/supervisord.conf

exit 0
