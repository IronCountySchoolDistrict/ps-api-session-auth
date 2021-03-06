#!/usr/bin/env bash

HOSTNAME="ps-api-session-auth"

echo "[+] Add PPAs to sources.list"
add-apt-repository -y ppa:ondrej/php > /dev/null 2>&1
apt-get -qq update

echo "[+] Install Apache"
apt-get install -y alien libaio1 apache2 > /dev/null 2>&1

echo "[+] Install PHP 7.0"
apt-get install -y php7.0 > /dev/null 2>&1
apt-get install -y php7.0-dev php7.0-mcrypt php7.0-mbstring php7.0-xml php7.0-zip libapache2-mod-php7.0 > /dev/null 2>&1

echo "[+] Install Oracle InstantClient"
alien -i /var/www/$HOSTNAME/_server/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
alien -i /var/www/$HOSTNAME/_server/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
printf "\n" | pecl install oci8

rm /etc/php/7.0/apache2/php.ini
rm /etc/php/7.0/cli/php.ini
ln -s /var/www/$HOSTNAME/_server/php/php.ini /etc/php/7.0/apache2/php.ini > /dev/null 2>&1
ln -s /var/www/$HOSTNAME/_server/php/php_cli.ini /etc/php/7.0/cli/php.ini > /dev/null 2>&1

echo "[+] Configure Apache"
a2enmod rewrite > /dev/null 2>&1
a2enmod headers > /dev/null 2>&1
a2enmod mime > /dev/null 2>&1
a2enmod deflate > /dev/null 2>&1
a2enmod setenvif > /dev/null 2>&1
a2enmod filter > /dev/null 2>&1
a2enmod expires > /dev/null 2>&1
a2enmod ssl > /dev/null 2>&1

openssl genrsa -out $HOSTNAME.key 2048
openssl req -new -x509 -key $HOSTNAME.key -out $HOSTNAME.cert -days 3650 -subj /CN=$HOSTNAME

ln -s /var/www/$HOSTNAME/_server/apache/$HOSTNAME.conf /etc/apache2/sites-available/$HOSTNAME.conf > /dev/null 2>&1
a2dissite 000-default > /dev/null 2>&1
a2ensite $HOSTNAME > /dev/null 2>&1

service apache2 restart > /dev/null 2>&1

rm -rf /var/www/html > /dev/null 2>&1

echo "[+] Install Composer"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer  > /dev/null 2>&1

echo "[+] Done!"
