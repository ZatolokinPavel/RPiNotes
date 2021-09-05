# Raspberry Pi notes
_Заметки и инструкции по настройке Raspberry Pi_

## План
1. Установить операционную систему Raspbian Stretch Lite. А именно: скачать с [офф. сайта](https://www.raspberrypi.org/downloads/raspbian/), записать на флешку с помощью **Win32DiskImager**, запустить на малине. Логин/пароль по умолчанию `pi` `raspberry`.
2. Настроить раскладку клавиатуры и язык системы. [(см. ниже)](#Раскладка-клавиатуры-и-локализация-консоли)
3. Провести начальную настройку через утилиту `sudo raspi-config`. [(см. ниже)](#Начальная-настройка)
4. Отключить скринсейвер. [(см. ниже)](#Отключение-скринсейвера)
5. Обновить всё что только можно [(см. ниже)](#Обновление)
6. Установка необходимого минимума программ [(см. ниже)](#Установка-необходимого-минимума-программ)
7. [Настроить SSH доступ и локальную сеть.](SSH.md)
8. [Настроить пользователей системы.](Users.md)
9. [Установить и настроить Samba для создания общей папки.](Samba.md)
10. Добавить репозиторий **bullseye**. [(см. ниже)](#Добавление-репозитория-bullseye)
11. [Настроить часы реального времени.](RTC.md)
12. [Настроить watchdog.](Watchdog.md)
13. Отключить Wi-Fi и Bluetooth [(см. ниже)](#Отключение-Wi-Fi-и-Bluetooth)
14. [Установить и настроить Nginx.](Nginx.md)
15. [Настроить SSL для Nginx (https).](SSL%20(https).md)
16. [Скачать сайт okfilm.com.ua и подключить его к Nginx.](https://github.com/ZatolokinPavel/okfilm_2018)
17. [Установить и настроить Erlang.](Erlang.md)
18. [Установить и настроить PostgreSQL](PostgreSQL.md)
19. [Скачать и запустить backend на эрланге.](https://github.com/ZatolokinPavel/raspberry_server)
20. [Настроить монтирование флешки](USB%20%D1%84%D0%BB%D0%B5%D1%88%D0%BA%D0%B0.md) чтобы хранить там общедоступные файлы.
21. [Поднять FTP сервер](FTP.md) для загрузки файлов в общую папку.
22. [Настроить систему проксирования на основе Tor.](TOR%20proxy.md)
23. При желании, [включить порт i2c0 на доп. клеммнике P5](Port%20I2C-0.md)
24. Если надо, установить [Apache, PHP и MySQL](PHP.md)

### Раскладка клавиатуры и локализация консоли
Взято отсюда http://blackdiver.net/it/linux/777  
Заходим в утилиту настройки  
`sudo raspi-config`  
Настраиваем раскладку клавиатуры:
1. Выбрать пункт `4 Localisation Options`
2. Выбрать пункт `I3 Change Keyboard Layout`
3. Далее ждём загрузки клавиатур и выбираем `Generic 105-key (Intl) PC` (или какая больше подходит)
4. На следующем экране выбрать `Other` для перехода в список всех раскладок
5. Выбрать страну — `Russian`
6. Выбрать русскую раскладку — просто `Russian`
7. Теперь выбираем метод переключения раскладок — предпочитаю `Control+Shift`
8. Клавиша временного переключения на латинскую раскладку — `No temporary switch`
9. Клавиша, которая будет использоваться в качестве AltGr — `The default for keyboard layout`
10. Клавиша, которая будет использоваться в качестве Compose key — `No compose key`
11. Использовать Control+Alt+Backspace для остановки X server — Yes (У меня такого не было).

Смена локализации:
1. Выбрать пункт `4 Localisation Options`
2. Выбрать пункт `I1 Change Locale`
3. Выбираем локализации `en_GB.UTF-8 UTF-8` и `ru_RU.UTF-8 UTF-8`  
   _Включение и выключение производится пробелом._
4. Далее нам предложат выбрать локализацию по умолчанию. Выбираем `ru_RU.UTF-8`

После выставления всех настроек нажимаем **Finish**. Раньше Raspberry предлагала перезагрузиться, нужно было соглашаться. Сейчас уже обходимся без перезагрузки.  
Если была перезагрузка, логинимся в систему, и понимаем, что вместо русских символов в консоли печатаются квадратики. Если перезагрузки не было, то пока ещё интерфейс на английском. Чтобы проблем с русскими буквами не было, выполняем команду:  
`sudo dpkg-reconfigure console-setup`  
Далее выбираем (увы, но на данном этапе вместо русских букв, скорее всего, будут квадратики, поэтому указываю пункт в меню):
* Используемая кодировка в консоли: UTF-8
* Используемая таблица символов: Определение оптимального набора символов (последний пункт)
* Консольный шрифт: Fixed или Позволить системе выбрать подходящий шрифт (последний пункт)
* Размер шрифта: 8×16

Теперь Raspberry Pi полностью поддерживает русский язык.


### Начальная настройка
Запустить программу начальной настройки  
`sudo raspi-config`  
В окне настройки в принципе почти всё понятно. Есть только несколько рекомендаций.
* **Advanced Options / Expand Filesystem** – здесь нужно увеличить root размер на весь размер карты памяти. Нужно сделать в первую очередь.
* **Internationalization Options** – здесь нужно будет установить локаль, часовой пояс и настроить клавиатуру. Об этом отдельно.
* **Advanced Options / Memory Split** – распределение памяти Raspberry Pi. Вам необходимо определиться, сколько оперативной памяти вы готовы выделить для графического процессора. При работе в консоли будет достаточно и 16 Мб, а вот для просмотра видео в графической оболочке придется пожертвовать 64-128 Мб. Выбранные значения могут быть только: 16, 32, 64, 128 или 256.
* **Advanced Options / SSH** – включение или выключение SSH сервера. Рекомендую вам включить SSH, если вы собираетесь использовать удаленное управление.

Остальное не описываю. После завершения настроек нажмите на клавиатуре Ctrl+F, выберите \<Finish\>. Raspberry Pi уйдет на перезагрузку для внесения изменений.

### Установка пароля пользователю 'root' в Raspberry Pi
По умолчанию пароль для рута не установлен. А значит зайти под рутом нельзя вообще. Можно только использовать sudo. И это хорошо. Так что не стоит устанавливать пароль руту.  

### Отключение скринсейвера
При подключении монитора напрямую (не по SSH) если долго не нажимать ничего на клавиатуре, то монитор становится черным. Это мешает и надо отключить. Для этого нужно изменить настройки в файле /etc/kbd/config  
`$ sudo vim.tiny /etc/kbd/config` (а нормального **vim**'а ещё и нету, как и **mc**)
```
BLANK_TIME=0
POWERDOWN_TIME=0
BLANK_DPMS=off
LEDS=+num            # заодно включить по умолчанию Num Lock
DO_VCSTIME=yes       # заодно отображать часы в верхнем правом углу консоли
```
`sudo reboot`

### Обновление
https://www.raspberrypi.org/documentation/raspbian/updating.md  
Нужно обновить все программы  
`$ sudo apt-get update` – обновить информацию о пакетах  
`$ sudo apt-get dist-upgrade`  
`$ sudo apt-get upgrade` – обновление всех установленных пакетов  
Затем обновить прошивку (не рекомендуется)  
`$ sudo apt-get install rpi-update` – программы обновления прошивки может и не быть  
`$ sudo rpi-update` – обновление прошивки ([описание программы](https://github.com/Hexxeh/rpi-update), не рекомендуется обновлять прошивку без особой нужды)  
`$ sudo reboot` – теперь надо перезагрузить  
Чистка  
`$ sudo apt-get clean` – после всех обновлений или установок можно чистить кэш установщика  
`$ sudo apt-get autoremove` – удалить неудалённые зависимости от уже удалённых пакетов  
`$ sudo apt-get autoclean` – почистить пакеты .deb которые больше не используются

### Установка необходимого минимума программ
`sudo apt-get install vim`  
`sudo apt-get install mc`  
`sudo apt-get install git`  
`sudo apt-get install htop`  
`sudo apt-get install ntpstat` - статус NTP, нужен для мониторилки сайта (уже не нужен)  

### Добавление репозитория bullseye
Этот репозиторий нужно добавить, чтобы из него ставить самые свежие версии пакетов с помощью apt-get. Это репозиторий будущей версии Debian. А текущая версия Debian - Buster (10). Посмотреть текущую версию можно командой `lsb_release -a`.  
Итак, в файле `/etc/apt/sources.list` уже есть строчка  
`deb http://raspbian.raspberrypi.org/raspbian/ buster main contrib non-free rpi`  
нужно просто добавить ещё и эту:  
`deb http://raspbian.raspberrypi.org/raspbian/ bullseye main contrib non-free rpi`  
Сохранить файл и обновить информацию о пакетах  
`$ sudo apt-get update`

### Отключение Wi-Fi и Bluetooth
Для моих задач они мне не нужны. Поэтому отключаем. Кроме того, вот:  

> On the Raspberry Pi Model 3B+ the hardware-based serial/UART device /dev/ttyAMA0 has been re-purposed to communicate with the built-in Bluetooth modem and is no longer mapped to the serial RX/TX pins on the GPIO header. Instead, a new serial port "/dev/ttyS0" has been provided which is implemented with a software-based UART (miniUART). This software-based UART ("/dev/ttyS0") does not support PARITY and some have experienced some stability issues using this port at higher speeds. If you don't need Bluetooth functionality, you can disable the BT modem and configure the RPi to use a device-tree overlay to re-map the hardware-based serial UART ("/dev/ttyAMA0") back to the GPIO header pins for TX/RX.  

Для отключения нужно в файле `/boot/config.txt` прописать строки  
`dtoverlay=disable-wifi`  
`dtoverlay=disable-bt`  
а также нужно отключить службу systemd, которая инициализирует модем, чтобы он не пытался использовать UART  
`$ sudo systemctl disable hciuart`  

### Дополнительные настройки  
Нужно сделать, чтобы светодиод **act** работал наоборот: во время простоя светился, а во время работы с флешкой чтобы гас. Для этого в файл `/boot/config.txt` нужно прописать  
`dtparam=act_led_activelow=on`  
но может понадобится прописать и `act-led overlay`, хотя мне пока не пригодилось. [Пояснение тут](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README).  

Ещё можно сделать кнопку выключения Raspbery Pi. Она будет только выключать. Не перезагружать и не включать заново. Но это уже что-то. Для этого тоже в `/boot/config.txt` нужно прописать  
`dtoverlay=gpio-shutdown,gpio_pin=21`  
Теперь если GPIO Pin 21 замкнуть на GND, то Raspbery Pi начнёт выключаться. Это получается нужно замкнуть между собой самые последние ножки на 40-штырьковом разъёме Raspbery Pi 3B+. Ножки 39 и 40.  
История появления этого devicetree overlay [здесь](https://www.stderr.nl/Blog/Hardware/RaspberryPi/PowerButton.html).  

Ещё нужно будет сделать управление кулером через ножку GPIO26. Для этого в файле `/boot/config.txt` нужно прописать  
`dtoverlay=gpio-fan,gpiopin=26,temp=45000`  
Таким образом, кулер будет включатся ножкой 37 при температуре процессора 45 градусов цельсия.  

О всех остальных devicetree overlay можно почитать здесь: https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README  
