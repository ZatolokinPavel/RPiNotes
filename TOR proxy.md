http://www.devdungeon.com/content/setting-tor-proxy-and-hidden-services-linux  
http://help.ubuntu.ru/wiki/tor  
Тут про установку на Raspberry Pi  
https://tor.stackexchange.com/questions/242/how-to-run-tor-on-raspbian-on-the-raspberry-pi

### Удаление старой версии
Нет, конечно же тора нет в предустановленных программах. Просто я уже накосячил и установил старую версию из репозитория по умолчанию. А она там не обновлялась несколько лет. Поэтому хотелось бы самую свежую версию.
Итак, у нас установлены пакеты `tor`, `tor-geoipdb` и `torsocks`.  
`sudo apt-get purge tor` удаляем tor и tor-geoipdb  
`sudo apt-get purge torsocks` и отдельно torsocks.  
`sudo apt-get autoremove` на всякий случай удаляем неудалённые зависимости от уже удалённых пакетов, хотя таких уже не должно быть.  
`sudo apt-get autoclean` заодно можно почистить пакеты .deb которые больше не используются (рекомендуется использовать периодически)  

### Установка
Так можно легко и быстро установить старую версию тора 0.2.5.12-4. `sudo apt-get install tor` Но она очень стара. Чуть ли не 2013 года. Поэтому будем ставить из исходников.  
Скачать исходники тут https://www.torproject.org/download/download.html.en#source (Source Tarball)  
Кидаем архив в какую-то папку, переходим туда, распаковываем архив и собираем его  
```bash
sudo apt-get install libevent-dev
tar -xvzf tor-0.3.0.7.tar.gz
cd tor-0.3.0.7/
./configure
make
```
Дальше можно запускать сразу из этой папки `src/or/tor` или установить его в систему `sudo make install` и запускать уже просто командой `tor`

### Удаление
Если устанавливал командой `sudo make install`, то можно удалить командой `sudo make uninstall` выполненной из папки, где собирались исходники. Не удалится только изменённый конфиг. И может пустая папка где останется.  
Команда `make install` вроде бы кидала файлы в папки
```
'/usr/local/bin'
'/usr/local/etc/tor'
'/usr/local/share/'
```

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
