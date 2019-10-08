# Настройка Watchdog  
Установить демон, который будет сбрасывать watchdog  
`sudo apt-get install watchdog`  
Обязательно он должен быть версии 5.15-1 или выше, потому что в версии ниже есть [какой-то баг](https://unix.stackexchange.com/questions/346224/problem-with-systemd-starting-watchdog).  
В файле `/etc/watchdog.conf` нужно раскомментировать строчку  
`watchdog-device = /dev/watchdog`  
и дописать  
`watchdog-timeout = 15`  

Теперь нужно запустить демона:  
`sudo systemctl start watchdog.service`  
`sudo systemctl enable watchdog.service` (если эта команда не вводится по Tab, то значит сервис уже включён)  

Ну а теперь в файл `/boot/config.txt` нужно добавить строку  
`dtparam=watchdog=on`  
и перезагрузить.  

### Проверка
`sudo systemctl is-active watchdog.service` - проверить, что сервис запущен сейчас  
`sudo systemctl is-enabled watchdog.service` - проверить, что сервис в автозапуске  
