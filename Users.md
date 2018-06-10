# Пользователи
Как настраивать пользователя pi я всё ещё не знаю.  
А здесь будет описано как добавить пользователя okfilm для только чтобы можно было загружать файлы на сайт в раздел "файлообменник" и не натупить больше нигде.  

### Полезные команды
`$ cat /etc/passwd` - просмотр списка всех пользователей в формате account:password:UID:GID:GECOS:directory:shell  
`$ w` или `$ who` - показать какие пользователи сейчас активны и что выполняют  
`$ lastlog` - дата последнего входа для каждого пользователя  

### Добавление пользователя okfilm для загрузки файлов  
https://www.dmosk.ru/miniinstruktions.php?mini=ssh-chroot

1. Собственно, добавляем пользователя okfilm:  
`$ sudo adduser okfilm`  
2. Добавляем пользователя в список разрешенных для доступа по ssh.  
Для этого в файле `/etc/ssh/sshd_config` дописываем его в параметр `AllowUsers`  
3. Запрещаем пользователю okfilm просматривать любые каталоги кроме его домашней папки. Для этого нужно в файле `/etc/ssh/sshd_config` закимментировать строчку  
`#Subsystem sftp /usr/lib/openssh/sftp-server`  
а в самый конец добавить следующие строки:  
```
Subsystem sftp internal-sftp -f AUTH -l VERBOSE
Match user okfilm
    ChrootDirectory %h
    ForceCommand internal-sftp
    AllowTcpForwarding no
```
4. Перезапускам sshd `$ sudo service ssh restart`  

### Изменение данных пользователя  
`chfn [параметры] [ПОЛЬЗОВАТЕЛЬ]` - поменять параметры GECOS для пользователя  
