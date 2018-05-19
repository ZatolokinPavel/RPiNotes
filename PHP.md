# Установка и настройка Apache, PHP, MySQL  
На случай если делаешь какие-то сайты на php и всяких Joomla и WordPress, и надо их где-то запускать для демонстрации.  

### Установка и настройка Apache  
Установка стандартная, версия подходит:  
```bash
sudo apt-get update
sudo apt-get install apache2
```
Все файлы конфигурации Apache находятся в папке `/etc/apache2`.  
Ещё апач создаёт файл `/var/www/html/index.html`, но вроде конфликтов это не вызывает.  

#### Полезные команды.  
Посмотреть запущен ли апач: `sudo systemctl status apache2.service`  
Перезапустить апач: `sudo service apache2 restart`  
Посмотреть, какой порт слушает апач: `sudo ss -tlpn`  
