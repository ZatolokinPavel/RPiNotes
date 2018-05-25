# Настройка FTP сервера  
Устанавливать будем FTP сервер `vsftpd`. Почему? А по кочану!  
`sudo apt-get install vsftpd`  

### Запуск и остановка  
Тут всё стандартно:  
`sudo service vsftpd start`  
`sudo service vsftpd stop`  
`sudo service vsftpd restart`
`sudo service vsftpd status`

### Настройка  
Основной файл настроек - это `/etc/vsftpd.conf`. Файл `/etc/ftpusers` содержит список пользователей, которым запрещен доступ по FTP.  
Пример параметров конфига `/etc/vsftpd.conf`:  
```
listen=YES      # запуск автономно в режиме демона но только для IPv4
listen_ipv6=NO  # если listen=YES, то эта команда должна быть выключена
anonymous_enable=NO
```
