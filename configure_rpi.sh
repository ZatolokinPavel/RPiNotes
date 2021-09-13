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
if [[ $(lsb_release -cs) = buster ]]
then
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo echo "deb http://raspbian.raspberrypi.org/raspbian/ bullseye main contrib non-free rpi" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install nginx
sudo rm /etc/apt/sources.list
sudo mv /etc/apt/sources.list.bak /etc/apt/sources.list
sudo apt-get update
else
sudo apt-get install nginx
fi
sudo git clone https://github.com/ZatolokinPavel/nginx.git /srv/nginx
sudo mkdir /srv/logs
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /srv/nginx/nginx.cfg /etc/nginx/sites-enabled/okfilm.com.ua
sudo mkdir /etc/nginx/includes
sudo ln -s /srv/nginx/includes/ /etc/nginx/includes/okfilm
sudo nginx -s reload
