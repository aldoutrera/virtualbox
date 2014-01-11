#!/usr/bin/env bash

# Upgrade Base Packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Web Packages
sudo apt-get install -y build-essential dkms re2c apache2 php5 php5-dev php-pear php5-xdebug php5-apcu php5-json php5-sqlite \
php5-mysql php5-pgsql php5-gd curl php5-curl memcached php5-memcached libmcrypt4 php5-mcrypt postgresql redis-server beanstalkd \
openssh-server git vim python2.7-dev

# Download Bash Aliases
wget -O ~/.bash_aliases https://raw2.github.com/taylorotwell/virtualbox/master/aliases

# Install MySQL
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password secret'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password secret'
sudo apt-get -y install mysql-server

# Configure Postgres
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/main/postgresql.conf
echo "host    all             all             10.0.2.2/32               md5" | sudo tee -a /etc/postgresql/9.1/main/pg_hba.conf
sudo -u postgres psql -c "CREATE ROLE taylor LOGIN UNENCRYPTED PASSWORD 'secret' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
sudo -u postgres /usr/bin/createdb --echo --owner=taylor laravel
sudo service postgresql restart

# Configure MySQL
sudo sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 10.0.2.15/' /etc/mysql/my.cnf
mysql -u root -p mysql -e "GRANT ALL ON *.* TO root@'10.0.2.2' IDENTIFIED BY 'secret';"
sudo service mysql restart

# Configure Mcrypt (Ubuntu 13.10)
sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt
sudo service apache2 restart

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install PHPUnit
sudo pear config-set auto_discover 1
sudo pear install pear.phpunit.de/phpunit

# Install Mailparse (For Snappy)
sudo pecl install mailparse
echo "extension=mailparse.so" | sudo tee -a /etc/php5/apache2/php.ini

# Enable PHP Error Reporting
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/cli/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/cli/php.ini
sudo sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php5/cli/php.ini

# Generate SSH Key
cd ~
mkdir .ssh
cd ~/.ssh
ssh-keygen -f id_rsa -t rsa -N ''

# Setup Authorized Keys
cd ~/.ssh
wget https://raw2.github.com/taylorotwell/virtualbox/master/authorized_keys

# Configure & Start Beanstalkd Queue
sudo sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd
sudo /etc/init.d/beanstalkd start

# Install Fabric & Hipchat Plugin
sudo apt-get install -y python-pip
sudo pip install fabric
sudo pip install python-simple-hipchat

# Install NodeJs
cd ~
wget http://nodejs.org/dist/v0.10.24/node-v0.10.24.tar.gz
tar -xvf node-v0.10.24.tar.gz
cd node-v0.10.24
./configure
make
sudo make install
cd ~
rm ~/node-v0.10.24.tar.gz
rm -rf ~/node-v0.10.24

# Install Grunt
sudo npm install -g grunt-cli

# Install Forever
sudo npm install -g forever

# Create Scripts Directory
mkdir ~/Scripts
mkdir ~/Scripts/PhpInfo

# Download Serve Script
cd ~/Scripts
wget https://raw2.github.com/taylorotwell/virtualbox/master/serve.sh

# Download Release Scripts
cd ~/Scripts
wget https://raw2.github.com/taylorotwell/virtualbox/master/release-scripts/illuminate-split-full.sh
wget https://raw2.github.com/taylorotwell/virtualbox/master/release-scripts/illuminate-split-heads.sh
wget https://raw2.github.com/taylorotwell/virtualbox/master/release-scripts/illuminate-split-tags.sh
wget https://raw2.github.com/taylorotwell/virtualbox/master/release-scripts/illuminate-split-single.sh

# Build PHP Info Site
echo "<?php phpinfo();" > ~/Scripts/PhpInfo/index.php

# Configure Apache Hosts
sudo a2enmod rewrite
echo "127.0.0.1  info.app" | sudo tee -a /etc/hosts
vhost="<VirtualHost *:80>
     ServerName info.app
     DocumentRoot /home/taylor/Scripts/PhpInfo
     <Directory \"/home/taylor/Scripts/PhpInfo\">
          Order allow,deny
          Allow from all
          Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/info.app.conf
sudo a2ensite info.app
sudo /etc/init.d/apache2 restart

# Install Beanstalkd Console
cd ~/Scripts
git clone https://github.com/ptrofimov/beanstalk_console.git Beansole
vhost="<VirtualHost *:80>
     ServerName beansole.app
     DocumentRoot /home/taylor/Scripts/Beansole/public
     <Directory \"/home/taylor/Scripts/Beansole/public\">
          Order allow,deny
          Allow from all
          Require all granted
          AllowOverride All
    </Directory>
</VirtualHost>"
echo "$vhost" | sudo tee /etc/apache2/sites-available/beansole.app.conf
sudo a2ensite beansole.app
sudo /etc/init.d/apache2 restart

# VirtualBox Guest Additions
sudo mount /dev/cdrom /media/cdrom
sudo sh /media/cdrom/VBoxLinuxAdditions.run
sudo usermod -aG vboxsf www-data
sudo usermod -aG vboxsf taylor

# Final Clean
cd ~
rm -rf tmp/

# Reboot
sudo reboot