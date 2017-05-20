http://www.devdungeon.com/content/setting-tor-proxy-and-hidden-services-linux

### Установка
`sudo apt-get install tor`  
Не самая свежая версия, конечно. Зато быстро и просто

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
