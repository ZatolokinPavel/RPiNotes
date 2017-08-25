# Установка и настройка Samba для создания общей папки   
Samba – это файловый сервер. Он позволяет настроить доступ к файлам по сети.

### Установка  
Устанавливать Samba лучше из репозитория по умолчанию для данной версии Debian (*jessie*). По крайней мере, у меня не заработала Samba из репозитория *stretch*.  
Если репозиторий *stretch* уже добавлен, следует закомментировать его в файле настройки apt ([см. тут](README.md#Добавление-репозитория-stretch)). Затем выполнить `sudo apt-get clean` и `sudo apt-get update`. И, если понадобится, удалить все предыдущие установки Samba и её компонентов.  
Команда для установки:  
`sudo apt-get install samba samba-common-bin`  
После установки можно возвращать/добавлять репозиторий *stretch*. И повторить `sudo apt-get clean` и `sudo apt-get update`.  

### Команды  
Запуск, перезапуск и остановка производится стандартными командами  
`sudo service smbd start`  
`sudo service smbd restart`  
`sudo service smbd stop`  

### Настройка  
Настраивается самба через конфиг `/etc/samba/smb.conf`  
Конфиг по умолчанию нужно переименовать. Например, командой ниже.  
`sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.old`  
После чего создать и открыть в редакторе чистый файл конфига.  
Новый конфиг должен быть таким:  
```
[global]
        workgroup = WORKGROUP
        netbios name = raspberrypi
        server string = Raspberry Pi server
        browseable = yes

        # какой-то тупой хак. Только так компьютер видно в сети
        security = user
        map to guest = bad user

        interfaces = lo, eth0
        #hosts allow = 192.168.1.

        # путь к файлу логов и его максимальный размер (количество строк)
        log file = /var/log/samba-log.%m
        max log size = 1000

[shared-local]
        comment = Share files with RaspberryPi on the local network
        path = /var/www/shared-local
        writeable = yes
        browseable = yes
        guest ok = yes
        read only = no
        create mask = 0777
        directory mask = 0777
```
