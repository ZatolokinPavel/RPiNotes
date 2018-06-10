# Пользователи
Как настраивать пользователя pi я всё ещё не знаю.  
А здесь будет описано как добавить пользователя okfilm для только чтобы можно было загружать файлы на сайт в раздел "файлообменник" и не натупить больше нигде.  

### Полезные команды
`$ cat /etc/passwd` - просмотр списка всех пользователей в формате account:password:UID:GID:GECOS:directory:shell  
`$ w` или `$ who` - показать какие пользователи сейчас активны и что выполняют  
`$ lastlog` - дата последнего входа для каждого пользователя  

### Добавление пользователя okfilm для загрузки файлов  
https://www.dmosk.ru/miniinstruktions.php?mini=ssh-chroot  
http://forum.ispsystem.ru/showthread.php?3528-Доступ-по-SSH-в-chroot-окружение/page4  

0. Сначала готовим папку для загрузки файлов.  
Для этого создаём папку `/mnt/shared-flash/`, настраиваем [монтирование в неё флешки](USB флешка.md), перемещаем все файлы из `/var/www/shared-global/` на флешку и ставим вместо папки `/var/www/shared-global/` символьную ссылку на папку `/mnt/shared-flash/`. Таким образом у нас весь файлообменник будет храниться на флешке.  
1. Собственно, добавляем пользователя okfilm:  
`$ sudo adduser okfilm`  
2. Добавляем пользователя в список разрешенных для доступа по ssh.  
Для этого в файле `/etc/ssh/sshd_config` дописываем его в параметр `AllowUsers`  
3. Запрещаем пользователю okfilm просматривать любые каталоги кроме его домашней папки. Для этого нужно в файле `/etc/ssh/sshd_config` закимментировать строчку  
`#Subsystem sftp /usr/lib/openssh/sftp-server`  
а в самый конец добавить следующие строки. Тем самым мы включаем встроенный sftp сервер вместо того, который внешний (Subsystem sftp /usr/lib/openssh/sftp-server)  
```
Subsystem sftp internal-sftp -f AUTH -l VERBOSE
Match user okfilm
    ChrootDirectory %h
    ForceCommand internal-sftp
    AllowTcpForwarding no
```
4. Перезапускам sshd `$ sudo service ssh restart`  
5. В домашней папке пользователя okfilm создаём папку `/home/okfilm/shared-global/` и меняем ей права на 777 и владельца на okfilm:  
`sudo chown okfilm:okfilm shared-global/`  
5. Под обычным пользователем переходим в домашнюю папку пользователя okfilm и создаём символьную ссылку на папку файлообменника:  
`/home/okfilm $ sudo ln -s /var/www/shared-global/`

### Изменение данных пользователя  
`chfn [параметры] [ПОЛЬЗОВАТЕЛЬ]` - поменять параметры GECOS для пользователя  
