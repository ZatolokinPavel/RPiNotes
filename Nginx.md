# Установка и настройка Nginx  

### Установка  
По умолчанию устанавливается версия 1.14.2. А хотелось бы самую свежую.  
Поэтому сначала [подключаем репозиторий bullseye](README.md#добавление-репозитория-bullseye), а затем выполняем  
`sudo apt-get update`  
`sudo apt-get install nginx`  
в результате установится самая свежая стабильная версия nginx 1.16.1  
Не забываем отключить репозиторий bullseye.  

### Неудачная установка из другого репозитория  
Это всё делать не нужно! Установка закончится ошибкой. Но для истории сохраню.  
Нужно было добавить в файл `/etc/apt/sources.list` строку  
`deb http://httpredir.debian.org/debian/ stretch-backports main contrib non-free`  
а затем выполнить команды  
```bash
sudo apt-get update
apt-cache policy nginx
sudo apt-get -t stretch-backports install nginx
```
Перед началом установки будет предупреждение, что невозможно аутентифицировать пакеты. Нужно согласиться всё равно установить. Или можно перед установкой добавить ключ репозитория в apt-get. Но лень.
В итоге установка завершилась ошибкой.  

### Настройка  
По настройке всего nginx глобально ничего конкретного сказать не могу. Надо почитать ещё. Но работает и так.  
1. В папке `/var/www/` создаём папку `okfilm.com.ua/` и устанавливаем её владельцем `pi`.  
2. В папку `/var/www/okfilm.com.ua/`, скачать свои конфиги [отсюда](https://github.com/ZatolokinPavel/nginx).  
3. Создать папку `/var/www/okfilm.com.ua/logs/` и устанавливаем её владельцем `pi`.  
4. Удалить символьную ссылку `/etc/nginx/sites-enabled/default` и добавить в эту папку символьную ссылку на свой конфиг  
   `sudo ln -s /var/www/okfilm.com.ua/nginx/nginx.cfg /etc/nginx/sites-enabled/okfilm.com.ua`  
5. Создать папку `/etc/nginx/includes` и добавить туда свои инклуды  
   `sudo ln -s /var/www/okfilm.com.ua/nginx/includes /etc/nginx/includes/okfilm`  
