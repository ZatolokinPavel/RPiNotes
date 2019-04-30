# Настройка доступа по SSH
Сначала нужно включить SSH сервер через утилиту настройки `sudo raspi-config`. Да, в общем-то, и всё. Доступ уже есть, всё работает.  
Ну если совсем всё плохо, и OpenSSH не установлен, то вот: `sudo apt-get install openssh-server`. Хотя на Raspberry Pi он установлен по умолчанию.

Теперь самое важное - настройка SSH, чтобы повысить его защищённость.

### Настройка SSH сервера
http://www.aitishnik.ru/linux/ssh-debian/nastroyka-openssh.html  

Настройки SSH сервера находятся в файле `/etc/ssh/sshd_config`  
После изменения настроек нужно перезапускать сервер ssh: `$ sudo service ssh restart`  
Готовый конфиг можно [скачать отсюда](/configs/sshd_config). Это если в новых версиях ssh не поменяли структуру конфига.  

Вот важные параметры из файла настроек:
```bash
Port 22                     # порт где будет доступен SSH (лучше нестандартный)
AddressFamily inet          # слушаем только IPv4 адреса (так проще)
#ListenAddress 0.0.0.0
#ListenAddress ::
Protocol 2                  # используй только вторую версию протокола

# HostKeys for protocol version 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
RekeyLimit default none     # ротация сеансового ключа по объёму трафика и по вермени

# Logging
SyslogFacility AUTH         # список каких событий будет записан в лог (/var/log/auth)
LogLevel INFO               # уровень детализации событий лога

# Authentication:
LoginGraceTime 20           # время ожидания авторизации = 20 сек
PermitRootLogin no          # запрещено заходить под рутом (пользуйтесь sudo)
StrictModes yes             # проверка прав и владение домашним каталогом пользователя
#MaxAuthTries 6
#MaxSessions 10
AllowUsers pi               # по ssh разрешено заходить ТОЛЬКО пользователю 'pi'

#RSAAuthentication yes      # аутентификация RSA (deprecated)
PubkeyAuthentication yes    # аутентификация по открытому ключу

# В этом файле хранятся публичные ключи для пользователя
AuthorizedKeysFile	.ssh/authorized_keys

AuthorizedPrincipalsFile none

AuthorizedKeysCommand none  # программа, которая будет искать открытые ключи пользователя
AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
HostbasedAuthentication no
#RhostsRSAAuthentication no # (deprecated)
# Change to yes if you don't trust ~/.ssh/known_hosts for HostbasedAuthentication
IgnoreUserKnownHosts yes
IgnoreRhosts yes            # Don't read the user's ~/.rhosts and ~/.shosts files

# To disable tunneled clear text passwords, change to no here!
PasswordAuthentication no   # отключил авторизацию по паролю. Подключение только по ключу
PermitEmptyPasswords no     # пустые пароли запрещены

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding no            # проброс иксов через ssh туннель
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no                # показывать сообщение дня из файла /etc/motd
PrintLastLog yes            # показывать, когда и откуда последний раз заходил
TCPKeepAlive no             # для поддержания соединения со стороны сервера (вариант похуже)
#UseLogin no
UsePrivilegeSeparation sandbox  # неавторизованный трафик в не привилегированном процессе
PermitUserEnvironment no
#Compression delayed
ClientAliveInterval 20      # время между пингами неработающей сессии (вариант получше)
ClientAliveCountMax 3       # кол-во пингов клиента до закрытия сессии (вариант получше)
#UseDNS no
#PidFile /var/run/sshd.pid
MaxStartups 10:30:20        # кол-во неавторизованных подключений (start:rate:full)
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
Banner none                 # скрываем информацию об операционке

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*         # разрешаем клиенту передать переменную окружения 'locale'

# override default of no subsystems
#Subsystem	sftp	/usr/lib/openssh/sftp-server
Subsystem	sftp internal-sftp -f AUTH -l VERBOSE   # встроенный лучше чем тот старый

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	X11Forwarding no
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
```
Проверить правильность конфига можно командой `sshd -t`  
Показать все-все задействованные опции можно командой `sshd -T`  

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

### Некоторые настройки PuTTY
* Поставь галочку «Disable application keypad mode» в разделе «Features» чтобы цифровая клавиатура работала и в VIM

### А если доступ по SSH с рабочего компа закрыт?  
Для этого сделаем SSH-клиент в браузере ([shellinabox](https://github.com/shellinabox/shellinabox)). Ещё описание [тут](https://ergoz.ru/web-ssh-klient-ssh-cherez-brauzer/).  
`sudo apt-get install shellinabox`  
Команды для запуска, остановки и прочего стандартные:  
```bash
sudo service shellinabox start
sudo service shellinabox stop
sudo service shellinabox restart
sudo service shellinabox reload
sudo service shellinabox status
```
В папке `/etc/shellinabox/` есть немного настроек. Но только касательно внешнего вида. Так как я предпочитаю тёмную тему, то переименуем файлы с темами, чтобы по-умолчанию была тёмная:  
```bash
pi@rpi:/etc/shellinabox/options-enabled $ sudo mv 00+Black\ on\ White.css 00_Black\ on\ White.css
pi@rpi:/etc/shellinabox/options-enabled $ sudo mv 00_White\ On\ Black.css 00+White\ On\ Black.css
```
Нужно проверить работоспособность. Для этого открываем в браузере https://my.server.domain:4200 и видим консоль.  

Ок. Теперь нужно немного защититься. В файле `/etc/default/shellinabox` в переменную `SHELLINABOX_ARGS` нужно добавить переменные ` –localhost-only –disable-ssl`. Первая, чтобы shellinabox был доступен извне только через nginx. А вторая - чтобы не нагружать лишний раз процессор, так как ssl обеспечит nginx.  
Перезапускаем shellinabox и проверяем доступ извне. Он должен пропасть.  
Теперь настраиваем обычный редирект (реверс-прокси) на nginx. Всё, должно работать.  
