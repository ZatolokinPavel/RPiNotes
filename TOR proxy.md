http://www.devdungeon.com/content/setting-tor-proxy-and-hidden-services-linux  
http://help.ubuntu.ru/wiki/tor  
Тут про установку на Raspberry Pi  
https://tor.stackexchange.com/questions/242/how-to-run-tor-on-raspbian-on-the-raspberry-pi  
Предлагали ещё использовать tun2socks в связке с тором, но пока врядли.  
https://code.google.com/archive/p/badvpn/wikis/tun2socks.wiki

### Удаление старой версии
Нет, конечно же тора нет в предустановленных программах. Просто я уже накосячил и установил старую версию из репозитория по умолчанию. А она там не обновлялась несколько лет. Поэтому хотелось бы самую свежую версию.
Итак, у нас установлены пакеты `tor`, `tor-geoipdb` и `torsocks`.  
`sudo apt-get purge tor` удаляем tor и tor-geoipdb  
`sudo apt-get purge torsocks` и отдельно torsocks.  
`sudo apt-get autoremove` на всякий случай удаляем неудалённые зависимости от уже удалённых пакетов, хотя таких уже не должно быть.  
`sudo apt-get autoclean` заодно можно почистить пакеты .deb которые больше не используются (рекомендуется использовать периодически)  

### Установка
Так можно легко и быстро установить старую версию тора 0.2.5.12-4. `sudo apt-get install tor` Но она очень стара. Чуть ли не 2013 года.

Будем ставить самую свежую из стабильных версий 0.2.9.10-1  
`sudo apt-get update`  
`sudo apt-get install tor -t stretch`

Ещё можно ставить из исходников версию 0.3.0.7, но там очень проблемно установить. И не знаю как сделать автозапуск.  
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

И ещё понадобится proxy-сервер Polipo
`sudo apt-get install polipo`

### Удаление
Если устанавливал командой `sudo make install`, то можно удалить командой `sudo make uninstall` выполненной из папки, где собирались исходники. Не удалится только изменённый конфиг. И может пустая папка где останется.  
Команда `make install` вроде бы кидала файлы в папки
```
'/usr/local/bin'
'/usr/local/etc/tor'
'/usr/local/share/'
```

### Настройка
Файл конфигурации находитя в одном из этих мест, смотря как устанавливали:  
`/etc/tor/torrc`  
`/usr/local/etc/tor/torrc`

Для начала нужно раскомментировать эти строчки и подставить туда свой IP
```
SOCKSPort 9050              # для лакальных подключений
SOCKSPort 192.168.x.x:9050  # для подключения с других компьютеров через SOCKS-прокси (тут ip RPi)

SOCKSPolicy accept 127.0.0.1
SOCKSPolicy accept 192.168.0.0/16   # по необходимости
SOCKSPolicy reject *
```
И, при необходимости, добавляем вот эти настройки. Хотя при использовании polipo они не нужны.
```
ClientOnly 1                # так, на всякий случай
TransPort 9100              # для локальных подключений
TransPort 192.168.x.x:9100  # для подключения с других компьютеров через transparent-прокси (тут ip RPi)
DNSPort 9053
DNSListenAddress 127.0.0.1
VirtualAddrNetwork 10.254.0.0/16  # виртуальные адреса для .onion ресурсов
AutomapHostsOnResolve 1     # не разобрался что это
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

### IPTables
`sudo iptables -t nat -L --line-numbers` посмотреть правила  
`sudo iptables -t nat -S` тоже посмотреть но в другом виде  
`sudo iptables -t nat -A PREROUTING -p tcp -s 192.168.1.2 --dport 80 -j REDIRECT --to-port 8123` добавить правило  
`sudo iptables -t nat -D PREROUTING 1` удалить правило  

### Установка tun2socks
https://github.com/ambrop72/badvpn/wiki/Tun2socks  
Установить утилиту CMake для настройки сборки tun2socks (около 20 мегабайт)  
`sudo apt-get update`  
`sudo apt-get install cmake`  
Скачать весь badvpn  
`git clone https://github.com/ambrop72/badvpn.git`  
Теперь собрать из всего badvpn только tun2socks  
```bash
mkdir badvpn-build
cd badvpn-build
cmake /path/to/badvpn -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_TUN2SOCKS=1
make
```
И пробуем установить  
`sudo make install`  
установится вот сюда:  
```
-- Installing: /usr/local/share/man/man7/badvpn.7
-- Installing: /usr/local/bin/badvpn-tun2socks
-- Installing: /usr/local/share/man/man8/badvpn-tun2socks.8
```

### Запуск tun2socks
Запускаем tun2socks:  
`sudo badvpn-tun2socks --tundev tun0 --netif-ipaddr 10.0.0.2 --netif-netmask 255.255.255.0 --socks-server-addr 127.0.0.1:9050`  
Смотрим, возможно в другой консоли, появился ли адаптер tun0:  
`ip link show`  
Проверяем работоспособность интерфейса:  
`curl --interface tun0 https://check.torproject.org/`

### Перенаправление трафика на tun2socks
Пока что перенаправляем весь трафик.  
Сначала нужно разрешить перенаправление в системе. Для этого нужно добавить строчку `net.ipv4.ip_forward=1` в файл `/etc/sysctl.conf` после чего перезагрузить Raspberry Pi.  
Теперь на Raspberry Pi добавляем такие правила в iptables:
```bash
sudo iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT
sudo iptables -A FORWARD -i tun0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 9080 -j DNAT --to-destination 10.0.0.2:80
sudo iptables -t nat -A POSTROUTING -d 10.0.0.2 -j MASQUERADE
```
