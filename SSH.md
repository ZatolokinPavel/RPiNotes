# Настройка доступа по SSH
Сначала нужно включить SSH сервер через утилиту настройки `sudo raspi-config`. Да, в общем-то, и всё. Доступ уже есть, всё работает. Ну если совсем всё плохо, и OpenSSH не установлен, то вот: `sudo apt-get install openssh-server`. Хотя на Raspberry Pi он установлен по умолчанию.

Теперь самое важное - настройка SSH, чтобы повысить его защищённость.

### Настройка SSH сервера
http://www.aitishnik.ru/linux/ssh-debian/nastroyka-openssh.html  

Настройки SSH сервера находятся в файле `/etc/ssh/sshd_config`  
После изменения настроек нужно перезапускать сервер ssh: `$ sudo service ssh restart`
