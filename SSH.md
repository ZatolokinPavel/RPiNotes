# Настройка доступа по SSH
Сначала нужно включить SSH сервер через утилиту настройки `sudo raspi-config`. Да, в общем-то, и всё. Доступ уже есть, всё работает.  
Ну если совсем всё плохо, и OpenSSH не установлен, то вот: `sudo apt-get install openssh-server`. Хотя на Raspberry Pi он установлен по умолчанию.

Теперь самое важное - настройка SSH, чтобы повысить его защищённость.

### Настройка SSH сервера
http://www.aitishnik.ru/linux/ssh-debian/nastroyka-openssh.html  

Настройки SSH сервера находятся в файле `/etc/ssh/sshd_config`  
После изменения настроек нужно перезапускать сервер ssh: `$ sudo service ssh restart`

Вот важные параметры из файла настроек:
```bash
Port 22                     # порт где будет доступен SSH (лучше нестандартный)
#ListenAddress ::
#ListenAddress 0.0.0.0
Protocol 2                  # используй только вторую версию протокола
# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
#Privilege Separation is turned on for security
UsePrivilegeSeparation yes      # разделение привилегий процессов чтобы не превышали права доступа

# Lifetime and size временного серверного ключа протокола SSH-1
#KeyRegenerationInterval 3600
#ServerKeyBits 1024

# Logging
SyslogFacility AUTH         # список каких событий будет записан в лог (/var/log/auth)
LogLevel INFO               # уровень детализации событий лога

# Authentication:
LoginGraceTime 20           # время ожидания авторизации = 20 сек
MaxStartups 10:30:20        # кол-во неавторизованных подключений (start:rate:full)
PermitRootLogin no          # запрещено заходить под рутом (пользуйтесь sudo)
PermitEmptyPasswords no     # пустые пароли запрещены
StrictModes yes             # проверка прав и владение домашним каталогом пользователя
AllowUsers pi               # по ssh разрешено заходить ТОЛЬКО пользователю 'pi'

RhostsAuthentication no     # небезопасная rhosts аутентификация запрещена
RSAAuthentication yes       # аутентификация RSA
PubkeyAuthentication yes    # аутентификация по открытому ключу
AuthorizedKeysFile	%h/.ssh/authorized_keys  # тут хранятся публичные ключи для пользователя

IgnoreRhosts yes            # Don't read the user's ~/.rhosts and ~/.shosts files
RhostsRSAAuthentication no  # For this to work you will also need host keys in /etc/ssh_known_hosts
HostbasedAuthentication no  # similar for protocol version 2
#IgnoreUserKnownHosts yes   # don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

PasswordAuthentication no   # отключил авторизацию по паролю. Подключение только по ключу

# Kerberos options
#KerberosAuthentication no
#KerberosGetAFSToken no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes

#X11Forwarding yes          # проброс иксов через ssh туннель
#X11DisplayOffset 10
PrintMotd no                # показывать сообщение дня из файла /etc/motd
PrintLastLog yes            # показывать, когда и откуда последний раз заходил
TCPKeepAlive no             # для поддержания соединения со стороны сервера (вариант похуже)
ClientAliveCountMax 3       # кол-во пингов клиента до закрытия сессии (вариант получше)
ClientAliveInterval 20      # время между пингами неработающей сессии
#UseLogin no

#Banner /etc/issue.net
DebianBanner no             # скрываем информацию об операционке

AcceptEnv LANG LC_*         # разрешаем клиенту передать переменную окружения 'locale'

Subsystem sftp /usr/lib/openssh/sftp-server

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
# В общем, запустить sshd можно будет только от имени root.
UsePAM yes
```
Проверить правильность конфига можно командой `ssh -t`  
Показать все-все задействованные опции можно командой `ssh -T`  

### Сертификаты для SSH
Сгенерировать пару публичный + приватный ключ командой  
`ssh-keygen -t rsa -b 4096`

> Преобразовывать приватный ключ в формат PKCS#8 не стоит. Всё равно PuTTY не поддерживает его. Но, если что, команда вот:   
> `openssl pkcs8 -topk8 -v2 des3 -in ~/.ssh/id_rsa.old -out ~/.ssh/id_rsa`

Публичный ключ скопировать в файл `~/.ssh/authorized_keys`  
Права при этом задаются такие:

* на папку `.ssh/` нужны права 700
* на все что в ней — 600.

В конфиге демона SSH (/etc/ssh/sshd_config) раскомментировать строку  
`AuthorizedKeysFile	%h/.ssh/authorized_keys`

Перезапустить демон SSH командой `sudo service ssh restart`

Приватный ключ скопировать на флешку и подставить в программу для доступа по SSH. Для putty придётся сконвертировать ключ в её формат с помощью утилиты **Putty Key Generator (puttygen)**, меню _Conversions -> Import key_.

Проверить работу по ключу, после чего запретить авторизацию по паролю в конфиге демона SSH:  
`PasswordAuthentication no`

### Дополнительные ссылки
Памятка пользователям ssh. О, тут много интересного, что можно сделать с помощью SSH!  
https://habrahabr.ru/post/122445/

21 способ обеспечения безопасности OpenSS. Всё по настроечному файлу оттуда я использовал.  
http://ubuntovod.ru/instructions/21-sposob-zashity-openssh.html
