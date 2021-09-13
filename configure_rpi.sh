#!/bin/bash -x

# Скрипт настройки Raspberry Pi с нуля. Устанавливает и настраивает всё то, что можно сделать через скрипт.
# Использовать согласно инструкции https://github.com/ZatolokinPavel/RPiNotes

echo "Raspberry Pi configuration starts"

sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get autoclean

sudo apt-get install vim git htop

# mc
sudo apt-get install mc crudini
mkdir -p ~/.config/mc
touch ~/.config/mc/ini
crudini --set ~/.config/mc/ini Panels navigate_with_arrows true
crudini --set ~/.config/mc/ini Midnight-Commander skin dark
mkdir -p /root/.config/mc
touch /root/.config/mc/ini
crudini --set /root/.config/mc/ini Panels navigate_with_arrows true
crudini --set /root/.config/mc/ini Midnight-Commander skin dark

# Nginx
sudo apt-get install nginx
sudo git clone https://github.com/ZatolokinPavel/nginx.git /srv/nginx
sudo mkdir /srv/logs
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /srv/nginx/nginx.cfg /etc/nginx/sites-enabled/okfilm.com.ua
sudo mkdir /etc/nginx/includes
sudo ln -s /srv/nginx/includes/ /etc/nginx/includes/okfilm
sudo nginx -s reload

# letsencrypt SSL (https) (not finished)
sudo apt-get install certbot
sudo crudini --set /etc/letsencrypt/cli.ini '' authenticator webroot
sudo crudini --set /etc/letsencrypt/cli.ini '' webroot-path '/var/www/html'
sudo crudini --set /etc/letsencrypt/cli.ini '' post-hook 'nginx -s reload'
sudo crudini --set /etc/letsencrypt/cli.ini '' text True

# site okfilm.com.ua (not finished)
sudo git clone https://github.com/ZatolokinPavel/okfilm_2018.git /srv/okfilm_2018
sudo mkdir /srv/cdn
sudo mkdir /srv/shared-global
