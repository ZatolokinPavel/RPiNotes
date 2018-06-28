# PostgreSQL
Буду пробовать PostgreSQL 10.

### Установка
Посмотреть что предлагают:  
`sudo apt-get update` - не забываем  
`apt-cache policy postgresql` - посмотреть какая версия будет устанавливаться  
`apt-cache policy postgresql-10` - посмотреть какая минорная версия PostgreSQL 10 будет установлена  
`apt-cache policy postgresql-9.6` - посмотреть какая минорная версия PostgreSQL 9.6 будет установлена  
Для установки версии 10 на Debian Stretch нужно [добавить репозиторий Buster](README.md#Добавление-репозитория-buster).  

Собственно установка:  
`sudo apt-get install postgresql` - установка ядра версии по умолчанию. Скорее всего самой последней.  
> Также можно указать, какую версию ставить, командами  
> `sudo apt-get install postgresql-10` или  
> `sudo apt-get install postgresql-9.6`  
При этом будут установлены и пакеты libpq5 postgresql-client-10 postgresql-client-common postgresql-common  
