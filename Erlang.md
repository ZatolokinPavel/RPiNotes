# Установка Erlang на Raspberry Pi
> На текущий момент самая свежая версия эрланга 21.3.2  
> На Erlang-Solutions для RaspberryPi есть только 20.1.7  
> В репозитории buster есть версия 21.2.6  
> Самую свежую версию нужно собирать самому.  

### Установка из репозитория bullseye.  
> Внимание! Не работает! С buster работало, а с bullseye - нет.  
1. [Подключаем репозиторий bullseye](README.md#добавление-репозитория-bullseye)  
2. `sudo apt-get update`  
3. `sudo apt-get install erlang`  
4. Отключаем репозиторий bullseye  
5. `sudo apt-get update`  

### Самостоятельная сборка из исходников
Это всё я подсмотрел тут: http://elinux.org/Erlang  
1.	Не забываем обновить информацию о пакетах  
`sudo apt-get update`
2.	Если совсем всё плохо, то устанавливаем wget. Хотя уж он-то должен быть.  
`sudo apt-get install wget`
3.	Теперь нужно установить две необходимые для сборки либы:  
`sudo apt-get install libssl-dev`  
`sudo apt-get install ncurses-dev`
4.	Далее скачиваем в любую папку исходники эрланга. Актуальную ссылку можно посмотреть на сайте http://www.erlang.org/  
`wget http://www.erlang.org/download/otp_src_18.3.tar.gz`
5.	Теперь нужно распаковать, зайти в папку с распакованными исходниками, сконфигурировать и собрать. Учтите, что конфигурация занимает много времени, а сборка так вообще может растянуться на пару часов.
```bash
tar -xzvf otp_src_18.3.tar.gz
cd otp_src_18.3/
./configure
make
```
6.	А теперь уже можно установить  
`sudo make install`
7.	После чего выйти из этой папки и удалить её  
```bash
cd ..  
sudo rm -R otp_src_18.3/
```
После конфигурации на моей Raspberry Pi оказалось что не получиться включить некоторые пакеты. Это jinterface, потому что нету компилятора Java, odbc (ODBC library – link check failed). Не будет работать wx, потому что не найден wxWidgets. А также завалилась сборка документации потому что отсутствуют xsltproc, fop и xmllint. Ну и фиг с ним.

### Отключение лишних библиотек перед сборкой
Если не нужно устанавливать весь пакет целиком, можно сэкономить время сборки и место на диске, отключив ненужные либы. Для этого нужно дёрнуть файл с именем SKIP в каждой библиотеке, которую хочешь отключить на Raspberry Pi. Вот пример приложений, которые обычно отключает чувак, писавший этот текст. На счёт xmerl’а я бы поспорил. И это нужно делать перед запуском команд `./configure` и `make`.

If you don't want to install everything that comes with the standard Erlang package, you can save space and time just by putting a file with the name SKIP in every library you don't want/need in your raspberry pi. This is the applications I usually skip. Do this before you run `./configure` and `make`.
```bash
touch lib/asn1/SKIP
touch lib/cosEvent/SKIP
touch lib/cosEventDomain/SKIP
touch lib/cosFileTransfer/SKIP
touch lib/cosNotification/SKIP
touch lib/cosProperty/SKIP
touch lib/cosTime/SKIP
touch lib/cosTransactions/SKIP
touch lib/diameter/SKIP
touch lib/eldap/SKIP
touch lib/ic/SKIP
touch lib/gs/SKIP
touch lib/megaco/SKIP
touch lib/orber/SKIP
touch lib/ose/SKIP
touch lib/otp_mibs/SKIP
touch lib/parsetools/SKIP
touch lib/percept/SKIP
touch lib/reltool/SKIP
touch lib/snmp/SKIP
touch lib/test_server/SKIP
touch lib/typer/SKIP
touch lib/webtool/SKIP
touch lib/wx/SKIP
touch lib/xmerl/SKIP
```
