#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='php'
PROJECTS_FOLDER='projects'

# create projects folder
sudo mkdir "/var/www/html/${PROJECTS_FOLDER}"

# adding PPA for PHP to the system
sudo add-apt-repository ppa:ondrej/php
sudo add-apt-repository ppa:nijel/phpmyadmin
sudo apt-get update

# install latest packages related to repositories from where software is installed from
sudo apt-get install software-properties-common python-software-properties

# update / upgrade
sudo apt-get update
sudo apt-get -y upgrade


# remove old PHP versions in case they are installed
sudo apt-get purge -y php5
sudo apt-get purge -y ^php5-*
sudo apt-get purge -y ^php-*

# install Apache 2.4 and PHP 7.1
sudo apt-get install -y apache2
sudo apt-get install -y php7.1
sudo apt-get install -y libapache2-mod-php7.1
sudo apt-get install -y php7.1-apcu
sudo apt-get install -y php7.1-bcmath
sudo apt-get install -y php7.1-cli
sudo apt-get install -y php7.1-common
sudo apt-get install -y php7.1-curl
sudo apt-get install -y php7.1-dev
sudo apt-get install -y php7.1-gd
sudo apt-get install -y php7.1-intl
sudo apt-get install -y php7.1-json
sudo apt-get install -y php7.1-mbstring
sudo apt-get install -y php7.1-mcrypt
sudo apt-get install -y php7.1-memcache
sudo apt-get install -y php7.1-memcached
sudo apt-get install -y php7.1-opcache
sudo apt-get install -y php7.1-soap
sudo apt-get install -y php7.1-sqlite3
sudo apt-get install -y php7.1-xdebug
sudo apt-get install -y php7.1-xml
sudo apt-get install -y php7.1-zip

# install MySQL and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
sudo apt-get -y install mysql-server
sudo apt-get install -y php7.1-mysql


# install phpMyAdmin and give password(s) to installer
# for simplicity I'm using the same password for MySQL and phpMyAdmin
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASSWORD"
sudo debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
sudo apt-get -y install phpmyadmin


# setup hosts file
VHOST=$(cat <<EOF
<VirtualHost *:80>
    ServerName lamp.l
    DocumentRoot "/var/www/html/${PROJECTS_FOLDER}"
    <Directory "/var/www/html/${PROJECTS_FOLDER}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-available/000-default.conf

# enable mod_rewrite
sudo a2enmod rewrite

# config php.ini for Apache2, replace default values with values suited for development
sed -i '/upload_max_filesize/s/= *2M/= 100M/' /etc/php/7.1/apache2/php.ini
sed -i '/post_max_size/s/= *8M/= 100M/' /etc/php/7.1/apache2/php.ini
#sed -i '/zlib.output_compression/s/= *Off/= On/' /etc/php/7.1/apache2/php.ini
sed -i '/max_execution_time/s/= *30/= 60/' /etc/php/7.1/apache2/php.ini
sed -i '/error_reporting/s/= *E_ALL & ~E_DEPRECATED & ~E_STRICT/= E_ALL/' /etc/php/7.1/apache2/php.ini
sed -i '/display_errors/s/= *Off/= On/' /etc/php/7.1/apache2/php.ini
sed -i '/^;date.timezone/s/;date.timezone =/date.timezone = Europe\/Bucharest/' /etc/php/7.1/apache2/php.ini

# restart Apache
sudo service apache2 restart

# config php.ini for CLI, replace default values with values suited for development
sed -i '/upload_max_filesize/s/= *2M/= 100M/' /etc/php/7.1/cli/php.ini
sed -i '/post_max_size/s/= *8M/= 100M/' /etc/php/7.1/cli/php.ini
#sed -i '/zlib.output_compression/s/= *Off/= On/' /etc/php/7.1/cli/php.ini
sed -i '/max_execution_time/s/= *30/= 60/' /etc/php/7.1/cli/php.ini
sed -i '/error_reporting/s/= *E_ALL & ~E_DEPRECATED & ~E_STRICT/= E_ALL/' /etc/php/7.1/cli/php.ini
sed -i '/display_errors/s/= *Off/= On/' /etc/php/7.1/cli/php.ini
sed -i '/^;date.timezone/s/;date.timezone =/date.timezone = Europe\/Bucharest/' /etc/php/7.1/cli/php.ini

# config apache2.conf
sed -i '$ a\\nServerName localhost' /etc/apache2/apache2.conf

# config /home/vagrant/.bashrc
sed -i '/^#force_color_prompt/s/#force_color_prompt/force_color_prompt/' /home/vagrant/.bashrc


# install Git
sudo apt-get install -y git

# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# install Symfony Installer
sudo mkdir -p /usr/local/bin
sudo curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
sudo chmod a+x /usr/local/bin/symfony

# install wp-cli
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

#install phpunit
wget https://phar.phpunit.de/phpunit.phar
chmod +x phpunit.phar
sudo mv phpunit.phar /usr/local/bin/phpunit

# Setup DB
#sudo mysql -u "root" "-p$PASSWORD" < "/var/www/html/databases/db.sql"
