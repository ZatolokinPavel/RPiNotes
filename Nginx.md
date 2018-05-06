# Установка и настройка Nginx  

### Установка  
Можно просто бахнуть `sudo apt-get install nginx`, но установится версия 1.10.3, а хотелось бы самую свежую. Поэтому будем колхозить с репозиториями.  
Добавляем в файл `/etc/apt/sources.list` строку  
`deb http://httpredir.debian.org/debian/ stretch-backports main contrib non-free`  
а затем выполняем команды  
```bash
sudo apt-get update
apt-cache policy nginx
sudo apt-get -t stretch-backports install nginx
```
Перед началом установки будет предупреждение, что невозможно аутентифицировать пакеты. Нужно согласиться всё равно установить. Или можно перед установкой добавить ключ репозитория в apt-get. Но лень.
