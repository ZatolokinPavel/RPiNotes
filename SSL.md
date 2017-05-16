# Настройка SSL
Настройка SSL для Nginx на Debian 8 (jessie) с использованием сертификатов Let's Encrypt

### Установка Certbot
Описано тут: https://certbot.eff.org/#debianjessie-nginx  
Сначала включаем репозиторий Jessie backports repo добавив строчку  
`deb http://ftp.debian.org/debian jessie-backports main`  
в файл **sources.list** (or add a new file with the ".list" extension to /etc/apt/sources.list.d/)  
и обновив список пакетов `apt-get update`

Теперь можно установить сам Certbot  
`$ sudo apt-get install certbot -t jessie-backports`
