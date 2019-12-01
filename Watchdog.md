# Настройка Watchdog  
Установить демон, который будет сбрасывать watchdog  
`sudo apt-get install watchdog`  
Обязательно он должен быть версии 5.15-1 или выше, потому что в версии ниже есть [какой-то баг](https://unix.stackexchange.com/questions/346224/problem-with-systemd-starting-watchdog).  
В файле `/etc/watchdog.conf` нужно раскомментировать строчку  
`watchdog-device = /dev/watchdog`  
а также можно раскомментировать и установить  
`interval = 10`  
что означает интервал в секундах между двумя операциями записи в watchdog устройство. Драйверы ядра ожидают команду записи каждую минуту. В противном случае система будет перезагружена.  
Ещё можно дописать  
`watchdog-timeout = 15`  
что означает the watchdog device timeout during startup. Если RPi будет загружаться долго, то чтобы не уйти в бесконечный цикл.  

Теперь нужно запустить демона (похоже, что не обязательно, может быть уже включён):  
`sudo systemctl start watchdog.service`  
`sudo systemctl enable watchdog.service` (если эта команда не вводится по Tab, то значит сервис уже включён)  

Ну а теперь в файл `/boot/config.txt` нужно добавить строку  
`dtparam=watchdog=on`  
и перезагрузить.  

### Проверка
`sudo systemctl is-active watchdog.service` - проверить, что сервис запущен сейчас  
`sudo systemctl is-enabled watchdog.service` - проверить, что сервис в автозапуске  

Люди проверяли командой `echo c > /proc/sysrq-trigger`, она же комбинация клавиш `Alt + SysRq + C`. Да, при этом падает ядро, но и перезагрузка происходит довольно быстро. И даже если закомментировать `dtparam=watchdog=on`. Так что не подходит.  

Проверить сам watchdog люди предлагают командой `:(){ :|: & };:`, но это fork bomb. Сильно нагружает проц. Но у меня сейчас watchdog не настроен на перевал при большой нагрузке. Так что не очень.  
