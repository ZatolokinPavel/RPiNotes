# Установка и настройка Apache, PHP, MySQL  
На случай если делаешь какие-то сайты на php и всяких Joomla и WordPress, и надо их где-то запускать для демонстрации.  

### Установка и настройка Apache  
Установка стандартная, версия подходит:  
```bash
sudo apt-get update
sudo apt-get install apache2
```
Все файлы конфигурации Apache находятся в папке `/etc/apache2`.  
Ещё апач создаёт файл `/var/www/html/index.html`, но вроде конфликтов это не вызывает.  

#### Полезные команды.  
Посмотреть запущен ли апач: `sudo systemctl status apache2.service`  
Запустить апач: `sudo service apache2 start`  
Перезапустить апач: `sudo apache2ctl restart`  
Посмотреть, какой порт слушает апач: `sudo ss -tlpn`  

#### Меняем порт, который слушает Apache.  
Так как на 80 порту у нас будет nginx, то апач не должен лезть на этот порт. Мало того, он ещё и не должен отвечать из внешнего интернета на том порту, на котором будет висеть. Для этого  
в файле `/etc/apache2/ports.conf`  
меняем `Listen 80` на `Listen 127.0.0.1:9280`,  
а также `Listen 443` на `Listen 127.0.0.1:9243`.  
Перезапускам апач. Ну и добавляем в nginx в нужном месте `proxy_pass http://127.0.0.1:9280;`. Теперь, даже если в настройках конкретного сайта будет указано `<VirtualHost *:80>`, то Apache всё равно будет слушать порт не 80, а 9280. Но вот если где-то в конфигах сайта всё же встретится ещё одна директива `Listen`, то Apache будет слушать и указанный порт тоже. Поэтому надо проверять наличие лишних директив `Listen` после каждого добавления нового сайта. Вот так:  
`grep -ri Listen /etc/apache2`  

#### Основные настройки Apache  
Основные настройки прописаны в файле `/etc/apache2/apache2.conf`.  
Здесь, пока что, я знаю только, что нужно удалить весь блок `<Directory /usr/share>`. Потому что сайты у меня будут располагаться только в папке `/var/www/`.  
Ещё в любом месте нужно дописать директиву `ServerName localhost`. Не очень понятно, зачем апачу она так сильно нужна, но он без неё ругается.  
Пока всё.  

#### Добавление нового сайта  
Где-нибудь, например в папке `/etc/apache2/sites-available/` создаём файл настройки виртуального хоста с таким содержимым:  
```xml
<VirtualHost *:9280>
    ServerName z.okfilm.com.ua
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/zhivoeslovo
    ErrorLog ${APACHE_LOG_DIR}/z.okfilm.com.ua-error.log
    CustomLog ${APACHE_LOG_DIR}/z.okfilm.com.ua-access.log common
</VirtualHost>
```
Затем в папке `/etc/apache2/sites-enabled/` нужно создать символьную ссылку на этот конфиг.  
`$ sudo ln -s ../sites-available/zhivoeslovo.conf zhivoeslovo.conf`  
Теперь создаём соответствующую папку для сайта и перезапускаем Apache.  

### Установка и настройка PHP
Устанавливаем php и некоторые дополнительные модули  
`sudo apt-get install php libapache2-mod-php php-mysql`  

### Установка и настройка MySQL  
Будем устанавливать MariaDB. MariaDB – это форк MySQL. Программы взаимозаменяемы, даже процессы называются одинаково.  
`sudo apt-get install mariadb-server`  
После завершения установки нужно запустить простой скрипт безопасности, который удалит некоторые настройки по умолчанию и чуть заблокирует доступ к нашей системе.  
`sudo mysql_secure_installation`  
Ниже приведу перевод всех вопросов скрипта, так как это важная часть обеспечения безопасности базы.  

> ```
> NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!
> ```  
> Примечание: запуск всех элементов этого скрипта рекомендуется для всех серверов MariaDB в продакшене (реальном рабочем использовании).  
> ```	
> In order to log into MariaDB to secure it, we'll need the current password for the root user.  If you've just installed MariaDB, and you haven't set the root password yet, the password will be blank, so you should just press enter here.
> ```
> Для того, чтобы войти в MariaDB для настройки безопасности, нам нужен текущий пароль пользователя root. Если вы только что установили MariaDB и ещё не установили пароль рута, то пароль будет пустым, т.е. просто нажмите Enter.
> ```
> Setting the root password ensures that nobody can log into the MariaDB root user without the proper authorisation.
> ```
> Установите пароль рута, чтобы никто другой не мог войти в MariaDB без надлежащей авторизации как пользователь root.
> ```
> Set root password? [Y/n]
> New password:
> Re-enter new password:
> ```
> Установить пароль root’а? [Да/нет]  
> Новый пароль:  
> Повторно введите новый пароль:  
> 
> Если у вас появилась строка «Sorry, you can't use an empty password here.» она означает, что пароль не может быть пустым, т.е. вы не ввели пароль.
> ```
> By default, a MariaDB installation has an anonymous user, allowing anyone to log into MariaDB without having to have a user account created for them.  This is intended only for testing, and to make the installation go a bit smoother.  You should remove them before moving into a production environment.
> Remove anonymous users? [Y/n]
> ```
> По умолчанию, установленная MariaDB имеет анонимного пользователя, позволяющего любому войти в MariaDB даже если для него не было создано пользовательского аккаунта. Это сделано в целях тестирования и упрощения установки. Вам следует удалить их перед переходом в реальное рабочее окружение.  
> Удалить анонимного пользователя? [Да/нет]
> ```
> Normally, root should only be allowed to connect from 'localhost'.  This ensures that someone cannot guess at the root password from the network.
> Disallow root login remotely? [Y/n]
> ```
> Обычно, root’у следует разрешать подключаться только с 'localhost'. Это гарантирует, что кто-то из сети не сможет угадать пароль root’а.  
> Отключить удалённый вход рута? [Да/нет]
> ```
> By default, MariaDB comes with a database named 'test' that anyone can access.  This is also intended only for testing, and should be removed before moving into a production environment.
> Remove test database and access to it? [Y/n]
> ```
> По умолчанию MariaDB поставляется с базой данных 'test', к которой может любой получить доступ. Это также сделано в целях тестирования и она должна быть удалена перед переходом в реальное рабочее окружение.  
> Удалить тестовую базу данных и доступ к ней? [Да/нет]
> ```
> Reloading the privilege tables will ensure that all changes made so far will take effect immediately.
> Reload privilege tables now? [Y/n]
> ```
> Перезагрузка таблицы привилегий гарантирует, что все сделанные изменения немедленно будут иметь эффект.  
> Перезагрузить таблицу привилегий сейчас? [Y/n]
> ```
> All done!  If you've completed all of the above steps, your MariaDB installation should now be secure.
> ```
> Всё сделано! Если вы завершили все вышеописанные шаги, ваша установленная MariaDB должна быть безопасной.  
> 
> Ещё раз о пароле MariaDB. Это должен быть надёжный и уникальный пароль. Думайте о нём как о пароле входа на ваш сервер. Он должен отличаться от пароля пользователя Linux.  

`sudo systemctl status mariadb.service`
`sudo mysql -u root -p`
`sudo service mysql restart`
