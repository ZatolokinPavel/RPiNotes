#!/bin/bash

# Скрипт настройки Raspberry Pi с нуля. Устанавливает и настраивает всё то, что можно сделать через скрипт.
# Использовать согласно инструкции https://github.com/ZatolokinPavel/RPiNotes

echo "Raspberry Pi configuration starts"

sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get autoclean

sudo apt-get install vim mc git htop

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
