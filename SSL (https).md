# Настройка SSL (https) для Nginx
Настройка SSL для Nginx на Debian с использованием сертификатов Let's Encrypt  
Источники:  
https://certbot.eff.org/#debianjessie-nginx  
https://habrahabr.ru/post/318952/ - статья, по которой всё делал  
https://habrahabr.ru/post/325230/ - статья, по которой улучшал безопасность  
Описание опций команды certbot  
https://certbot.eff.org/docs/using.html#certbot-command-line-options  
Проверка SSL  
https://www.ssllabs.com/ssltest/  

> Если выполнял общий скрипт настройки, то смотри сразу в [самый низ](#Итого)  

### Установка Certbot
`$ sudo apt-get update`  
`$ sudo apt-get install certbot`

### Настройка
Запишем основные настройки в файл конфигурации, который certbot ожидает найти в `/etc/letsencrypt/cli.ini:`
```
authenticator = webroot
webroot-path = /var/www/html
post-hook = nginx -s reload
text = True
```

### Подготовка Nginx
Certbot будет создавать необходимые для проверки прав на домен файлы в подкаталогах ниже по иерархии к указанному. Вроде таких: `/var/www/html/.well-known/acme-challenge/example.html`. Эти файлы должны быть доступны из сети на целевом домене по крайней мере по HTTP: `http://www.example.com/.well-known/acme-challenge/example.html`. Поэтому в общем случае для получения сертификата необходимо во всех блоках server добавить следующий блок до других блоков location:
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

Автоматическое обновление сертификатов уже должно быть настроено. В случае Debian, крон уже создан при установке. Это файл `/etc/cron.d/certbot`.  
Если в конфиге не задано `allow-subset-of-names = True`, то надо немного подредактировать крон. А именно, добавить ключ `--allow-subset-of-names`, который разрешит игнорировать не существующие домены при получении сертификата. Должно получатся приблизительно так:
```bash
# последняя строка в /etc/cron.d/certbot
0 */12 * * * root test -x /usr/bin/certbot -a \! -d /run/systemd/system && perl -e 'sleep int(rand(43200))' && certbot -q --allow-subset-of-names renew
```
Если были ещё дополнительные команды в этом кроне, то их оставляем.

### Проверка сертификата
Можно проверить полученный сертификат. Как минимум, посмотреть его срок годности.  
`sudo openssl x509 -text -in /etc/letsencrypt/live/example.com/cert.pem`

### Настройка Nginx
<details>
  <summary>Эти настройки уже прописаны в моём конфиге nginx.</summary>

Необходимо доработать конфиг, чтобы переключить сайт на работу по https. Для этого в блоке **server** соответствующего сайта добавляем вот эти директивы:
```nginx
server {
    # === server_name и listen которые уже были ===
    listen                  443 ssl;
    
    ssl_certificate         "/etc/letsencrypt/live/okfilm.com.ua/fullchain.pem";
    ssl_certificate_key     "/etc/letsencrypt/live/okfilm.com.ua/privkey.pem";
    ssl_trusted_certificate "/etc/letsencrypt/live/okfilm.com.ua/chain.pem";
    ssl_ciphers             EECDH:+AES256:-3DES:RSA+AES:RSA+3DES:!NULL:!RC4;    # разрешённые шифры
    
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
И нужно сделать перенаправление с http на https версию сайта. Пока так, но это не самый лучший вариант.
```nginx
# Редирект с http на https
server {
    server_name okfilm.com.ua;
    listen 80 default_server;
    return 301 https://okfilm.com.ua$request_uri;
}
# Редирект с www на домен без www https
server {
    server_name www.okfilm.com.ua;
    listen 80;
    listen 443;
    listen [::]:80;                 # IPv6 адрес:порт
    return 301 https://okfilm.com.ua$request_uri;
}
```

</details>

### Исправление соединения WebSocket
Если до этого на javascript соединение WebSocket устанавливалось такой командой:  
`ws = new WebSocket("ws://"+location.host+"/ws/");`  
то теперь это надо делать вот так:  
```javascript
var scheme = (window.location.protocol == 'https:') ? 'wss://' : 'ws://';
var host = window.location.host;                    // хост и порт
ws = new WebSocket(scheme+host+"/back/ws/");
```

### Итого
После выполнения общего [скрипта настройки](https://github.com/ZatolokinPavel/RPiNotes#Скрипт-настройки), нужно будет вручную выполнить следующее:  
1. Зарегистрироваться  
   `$ sudo certbot register --email me@example.com`  
2. Как-то настроить nginx на работу без сертификатов. В каждом server убрать ssl и закоментарить пути к сертификатам.  
3. Получить сертификат в тестовом режиме на все домены    
   ```sh
   sudo certbot certonly --dry-run --cert-name okfilm.com.ua -d okfilm.com.ua -d www.okfilm.com.ua -d cdn.okfilm.com.ua -d h.okfilm.com.ua -d f.okfilm.com.ua -d bus-pidgorodne.dp.ua -d www.bus-pidgorodne.dp.ua -d h.bus-pidgorodne.dp.ua -d f.bus-pidgorodne.dp.ua
   ```  
4. Получить реальные сертификаты. Для этого выполнить предыдущую команду без ключа `--dry-run`.  
5. Откатить изменения в конфиге nginx с помощью git и `sudo nginx -s reload`.  
6. Готово.  
