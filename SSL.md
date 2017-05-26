# Настройка SSL
Настройка SSL для Nginx на Debian 8 (jessie) с использованием сертификатов Let's Encrypt  
Источники:  
https://certbot.eff.org/#debianjessie-nginx  
https://habrahabr.ru/post/318952/  
Описание опций команды certbot  
https://certbot.eff.org/docs/using.html#certbot-command-line-options

### Установка Certbot
_Вариант получше_  
Подключить репозиторий Debian 9 Stretch (не знаю как) и установить этой командой:  
`$ sudo apt-get update`  
`$ sudo apt-get install certbot -t stretch`

_Вариант похуже_  
Описано тут: https://certbot.eff.org/#debianjessie-nginx  
Сначала включаем репозиторий Jessie backports repo добавив строчку  
`deb http://ftp.debian.org/debian jessie-backports main`  
в файл **sources.list** (or add a new file with the ".list" extension to /etc/apt/sources.list.d/)  
Теперь можно обновить список пакетов и установить сам Certbot  
`$ sudo apt-get update`  
`$ sudo apt-get install certbot -t jessie-backports`

### Настройка
Запишем основные настройки в файл конфигурации, который certbot ожидает найти в `/etc/letsencrypt/cli.ini:`
```
authenticator = webroot
webroot-path = /var/www/html
post-hook = service nginx -s reload
text = True
```

### Подготовка Nginx
Certbot будет создавать необходимые для проверки прав на домен файлы в подкаталогах ниже по иерархии к указанному. Вроде таких: `/var/www/html/.well-known/acme-challenge/example.html`. Эти файлы должны будут быть доступны из сети на целевом домене по крайней мере по HTTP: `http://www.example.com/.well-known/acme-challenge/example.html`. Поэтому в общем случае для получения сертификата необходимо во всех блоках server добавить следующий блок до других блоков location:
```nginx
location /.well-known {
    root /var/www/html;
}
```
И папку `/var/www/html/.well-known/acme-challenge/` создать на диске. Права доступа можно оставить рутовые, так как Certbot, наверное, будет запускаться под рутом.

### Регистрация в Let's Encrypt
Регистрацию нужно сделать только один раз:  
`certbot register --email me@example.com`
