http://www.devdungeon.com/content/setting-tor-proxy-and-hidden-services-linux  
http://help.ubuntu.ru/wiki/tor  
Тут про установку на Raspberry Pi  
https://tor.stackexchange.com/questions/242/how-to-run-tor-on-raspbian-on-the-raspberry-pi

### Удаление старой версии
Нет, конечно же тора нет в предустановленных программах. Просто я уже накосячил и установил старую версию из репозитория по умолчанию. А она там не обновлялась несколько лет. Поэтому хотелось бы самую свежую версию.
Итак, у нас установлены пакеты `tor`, `tor-geoipdb` и `torsocks`.  
Удаляем tor и tor-geoipdb  
`sudo apt-get purge tor`  
И удаляем неудалённые зависимости от уже удалённых пакетов (torsocks)  
`sudo apt-get autoremove`  
Заодно можно почистить пакеты .deb которые больше не используются (рекомендуется использовать периодически)  
`sudo apt-get autoclean`

### Установка
Так можно легко и быстро установить старую версию тора 0.2.5.12-4. `sudo apt-get install tor` Но она очень стара. Чуть ли не 2013 года.  


### Настройка
Просмотр/изменение конфигурации  
`sudo vim /etc/tor/torrc`

You can change the default port, or specify multiple IP addresses and ports for binding.
```
SOCKSPort 9050 # Default
SOCKSPort 10.10.1.23:9999 # Bind to specific IP/port
```

### Запуск
Control the service using standard systemctl or service commands
```
service tor restart
systemctl restart tor
```

### Проверка соединения на локальной машине
`curl --socks5-hostname localhost:9050 https://check.torproject.org`  
На винде проверять будем, открыв адрес `https://check.torproject.org/`
