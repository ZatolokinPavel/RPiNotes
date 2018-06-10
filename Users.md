# Пользователи
Как настраивать пользователя pi я всё ещё не знаю.  
А здесь будет описано как добавить пользователя okfilm для только чтобы можно было загружать файлы на сайт в раздел "файлообменник" и не натупить больше нигде.  

### Полезные команды
`$ cat /etc/passwd` - просмотр списка всех пользователей в формате account:password:UID:GID:GECOS:directory:shell  
`$ w` или `$ who` - показать какие пользователи сейчас активны и что выполняют  
`$ lastlog` - дата последнего входа для каждого пользователя  

### Добавление нового пользователя  
Полная команда для добавления обычного пользователя:  
`adduser [--home КАТ] [--shell ОБОЛОЧКА] [--no-create-home] [--uid ID] [--firstuid ID] [--lastuid ID] [--gecos GECOS] [--ingroup ГРУППА | --gid ID] [--disabled-password] [--disabled-login] [--add_extra_groups] ПОЛЬЗОВАТЕЛЬ`  

Мне нужно добавить пользователя okfilm самой простой командой:  
`adduser okfilm`  
Добавляем пользователя в список разрешенных для доступа по ssh. Для этого в файле `/etc/ssh/sshd_config` дописываем его в параметр `AllowUsers`  

### Изменение данных пользователя  
`chfn [параметры] [ПОЛЬЗОВАТЕЛЬ]` - поменять параметры GECOS для пользователя  