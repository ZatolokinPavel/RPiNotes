# Установка и настройка Samba для создания общей папки   
Samba – это файловый сервер. Он позволяет настроить доступ к файлам по сети.

### Установка  
`sudo apt-get install samba samba-common-bin -t jessie`  

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
