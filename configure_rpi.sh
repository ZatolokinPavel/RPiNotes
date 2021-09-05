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
