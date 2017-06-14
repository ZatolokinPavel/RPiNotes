# Настройка SSL (https) для Nginx
Настройка SSL для Nginx на Debian 8 (jessie) с использованием сертификатов Let's Encrypt  
Источники:  
https://certbot.eff.org/#debianjessie-nginx  
https://habrahabr.ru/post/318952/ - статья, по которой всё делал  
https://habrahabr.ru/post/325230/ - статья, по которой улучшал безопасность  
Описание опций команды certbot  
https://certbot.eff.org/docs/using.html#certbot-command-line-options  
Проверка SSL  
https://www.ssllabs.com/ssltest/  

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
post-hook = nginx -s reload
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
`$ sudo certbot register --email me@example.com`  
После выполнения команды получим вот это сообщение:  
```
IMPORTANT NOTES:
 - If you lose your account credentials, you can recover through
   e-mails sent to me@example.com.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```

### Получение сертификата
У Let's Encrypt есть лимиты на количество обращений за сертификатами, потому сначала попробуем получить необходимый сертификат в режиме для тестов:  
`$ sudo certbot certonly --dry-run -d example.com -d www.example.com`  
В конце программа должна отчитаться об успешной работе: `The dry run was successful.`

Если всё норм, тогда получаем сертификаты уже в самом деле. Для этого всего лишь нужно запустить вот эту команду. Остальные опции для неё не очень-то и нужны в нашем случае.  
`$ sudo certbot certonly -d example.com -d www.example.com`

И ещё нужно настроить автоматическое обновление сертификатов. В случае Debian крон уже создан при установке. Это файл `/etc/cron.d/certbot`. Его только надо немного подредактировать. А именно, изменить минуту, в которую будет происходить проверка, и добавить ключ `--allow-subset-of-names`, который разрешит игнорировать не существующие домены при получении сертификата. Должно получатся приблизительно так:
```bash
# последняя строка в /etc/cron.d/certbot
42 */12 * * * certbot renew --quiet --allow-subset-of-names
```
Если были ещё дополнительные команды в этом кроне, то их оставляем.

### Проверка сертификата
Можно проверить полученный сертификат. Как минимум, посмотреть его срок годности.  
`sudo openssl x509 -text -in /etc/letsencrypt/live/example.com/cert.pem`

### Настройка Nginx
Теперь осталось только переключить сайт на работу по https. Для этого в блоке **server** соответствующего сайта добавляем вот эти директивы:
```nginx
server {
    # === server_name и listen которые уже были ===
    listen                  443 ssl;
    
    ssl_certificate         "/etc/letsencrypt/live/okfilm.com.ua/fullchain.pem";
    ssl_certificate_key     "/etc/letsencrypt/live/okfilm.com.ua/privkey.pem";
    ssl_trusted_certificate "/etc/letsencrypt/live/okfilm.com.ua/chain.pem";
    
    ssl_stapling            on;     # прикрепление OCSP-ответов сервером
    ssl_stapling_verify     on;     # проверка сервером ответов OCSP
    resolver                127.0.0.1 8.8.8.8 ipv6=off;     # для преобразования имени хоста OCSP responder’а
    
    # исключим возврат на http-версию сайта
    add_header Strict-Transport-Security "max-age=31536000";
    # явно "сломаем" все картинки с http://
    add_header Content-Security-Policy "block-all-mixed-content";
    
    # === всё остальное что тут было ===
}
```
