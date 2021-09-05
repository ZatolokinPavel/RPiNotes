# Установка и настройка Nginx  

### Установка  
По умолчанию устанавливается версия 1.14.2. А хотелось бы самую свежую.  
Поэтому сначала [подключаем репозиторий bullseye](README.md#добавление-репозитория-bullseye), а затем выполняем  
`sudo apt-get update`  
`sudo apt-get install nginx`  
в результате установится самая свежая стабильная версия nginx 1.16.1  
Не забываем отключить репозиторий bullseye.  

### Неудачная установка из другого репозитория  
<details>
  <summary>Это всё делать не нужно! Установка закончится ошибкой. Но для истории сохраню.</summary>
   
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
   
</details>

### Настройка  
По настройке всего nginx глобально ничего конкретного сказать не могу. Надо почитать ещё. Но работает и так.   
1. В папку `/srv/`, скачать свои конфиги [отсюда](https://github.com/ZatolokinPavel/nginx).  
2. Создать папку `/srv/logs/`. ~~Устанавливаем её владельцем `pi`~~.  
3. Удалить символьную ссылку `/etc/nginx/sites-enabled/default`
4. Создать символьную ссылку на основной конфиг  
   `sudo ln -s /srv/nginx/nginx.cfg /etc/nginx/sites-enabled/okfilm.com.ua`
5. Создать папку `/etc/nginx/includes`
6. Создать символьную ссылку на мою папку includes  
   `sudo ln -s /srv/nginx/includes/ /etc/nginx/includes/okfilm`
7. Применить: `sudo nginx -s reload`
