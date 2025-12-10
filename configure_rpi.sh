#!/bin/bash -x

# Скрипт настройки Raspberry Pi с нуля. Устанавливает и настраивает всё то, что можно сделать через скрипт.
# Использовать согласно инструкции https://github.com/ZatolokinPavel/RPiNotes

echo "Raspberry Pi configuration starts"

# configure Device Tree Overlays
sudo sh -c "echo '' >> /boot/firmware/config.txt"
sudo sh -c "echo 'dtoverlay=disable-wifi' >> /boot/firmware/config.txt"
sudo sh -c "echo 'dtoverlay=disable-bt' >> /boot/firmware/config.txt"
sudo systemctl disable hciuart
sudo sh -c "echo 'dtparam=act_led_activelow=on' >> /boot/firmware/config.txt"
sudo sh -c "echo 'dtoverlay=gpio-shutdown,gpio_pin=21' >> /boot/firmware/config.txt"
sudo sh -c "echo 'dtoverlay=gpio-fan,gpiopin=26,temp=60000' >> /boot/firmware/config.txt"
sudo sh -c "echo 'dtoverlay=i2c-rtc,ds3231' >> /boot/firmware/config.txt"

# Disk partitioning
sudo parted /dev/mmcblk0 resizepart 2 17453MB
sudo resize2fs /dev/mmcblk0p2
sudo parted /dev/mmcblk0 -- mkpart primary ext4 17GB -1s
sudo mkfs.ext4 -L userdisk /dev/mmcblk0p3

# update all
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get upgrade
sudo apt-get clean
sudo apt-get autoremove
sudo apt-get autoclean

# install some programs
sudo apt-get install vim git htop i2c-tools

# mc
sudo apt-get install mc crudini
mkdir -p ~/.config/mc
touch ~/.config/mc/ini
crudini --set ~/.config/mc/ini Panels navigate_with_arrows true
crudini --set ~/.config/mc/ini Midnight-Commander skin dark
sudo -u root mkdir -p /root/.config/mc
sudo -u root touch /root/.config/mc/ini
sudo crudini --set /root/.config/mc/ini Panels navigate_with_arrows true
sudo crudini --set /root/.config/mc/ini Midnight-Commander skin dark


# partition 1 mount
sudo mkdir /mnt/userdisk/
sudo sh -c "cat << EOF > /etc/systemd/system/mnt-userdisk.mount
[Unit]
Description=User data disk (to avoid overfill the system disk)
[Mount]
What=/dev/mmcblk0p3
Where=/mnt/userdisk
Type=ext4
Options=defaults,noatime
[Install]
WantedBy=multi-user.target
EOF"

# partition 2 mount
sudo mkdir /mnt/okdisk/
sudo sh -c "cat << EOF > /etc/systemd/system/mnt-okdisk.mount
[Unit]
Description=OkFILM global share
[Mount]
What=/dev/disk/by-uuid/986769cb-0803-44f7-8819-8dd0ab0b5ee7
Where=/mnt/okdisk
Type=ext4
Options=defaults,noatime
DirectoryMode=0755
TimeoutSec=5
[Install]
WantedBy=multi-user.target
EOF"
sudo sh -c "cat << EOF > /etc/systemd/system/mnt-okdisk.automount
[Unit]
Description=OkFILM global share
[Automount]
Where=/mnt/okdisk
[Install]
WantedBy=multi-user.target
EOF"

# partition 3 mount
sudo mkdir /mnt/photodisk/
sudo sh -c "cat << EOF > /etc/systemd/system/mnt-photodisk.mount
[Unit]
Description=Photo album
[Mount]
What=/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000
Where=/mnt/photodisk
Type=ext4
Options=defaults,noatime
DirectoryMode=0755
TimeoutSec=5
[Install]
WantedBy=multi-user.target
EOF"
sudo sh -c "cat << EOF > /etc/systemd/system/mnt-photodisk.automount
[Unit]
Description=Photo album
[Automount]
Where=/mnt/photodisk
[Install]
WantedBy=multi-user.target
EOF"

sudo systemctl daemon-reload
sudo systemctl enable --now mnt-userdisk.mount
sudo systemctl enable --now mnt-okdisk.automount
sudo systemctl enable --now mnt-photodisk.automount

# Nginx
sudo apt-get install nginx
sudo git clone https://github.com/ZatolokinPavel/nginx.git /srv/nginx
sudo mkdir /srv/logs
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /srv/nginx/nginx.cfg /etc/nginx/sites-enabled/okfilm.com.ua
sudo mkdir /etc/nginx/includes
sudo ln -s /srv/nginx/includes/ /etc/nginx/includes/okfilm
sudo nginx -s reload

# letsencrypt SSL (https) (not all commands)
sudo apt-get install certbot
sudo crudini --set /etc/letsencrypt/cli.ini '' authenticator webroot
sudo crudini --set /etc/letsencrypt/cli.ini '' webroot-path '/var/www/html'
sudo crudini --set /etc/letsencrypt/cli.ini '' post-hook 'nginx -s reload'
sudo crudini --set /etc/letsencrypt/cli.ini '' text True
sudo mkdir -p /var/www/html/.well-known/acme-challenge

# site okfilm.com.ua
sudo git clone https://github.com/ZatolokinPavel/okfilm_2018.git /srv/okfilm_2018
sudo mkdir /srv/cdn
sudo mkdir /mnt/okdisk/shared-global
sudo chmod 777 /mnt/okdisk/shared-global
sudo ln -s /mnt/okdisk/shared-global/ /srv/shared-global

# erlang 23.2.6
sudo apt-get install erlang
#wget https://packages.erlang-solutions.com/erlang-solutions_2.0_all.deb
#sudo dpkg -i erlang-solutions_2.0_all.deb
#rm -f erlang-solutions_2.0_all.deb
#sudo apt-get update
#sudo apt-get install esl-erlang=1:22.1.6-1
