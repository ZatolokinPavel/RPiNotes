# Raspberry Pi notes
_Заметки и инструкции по настройке Raspberry Pi_  
Для настройки системы с нуля необходимо взять пустую карту памяти и выполнить все пункты из этого плана по порядку. Если что-то уже не нужно - можно не выполнять.  
Все пункты, с пометкой [sh] выполнять не нужно - они есть в скрипте.  

## План
1. Установить операционную систему Raspberry Pi OS Lite. [(обязательно см. ниже)](#Установка-операционной-системы-Raspberry-Pi-OS-Lite)
2. Настроить раскладку клавиатуры и язык системы. [(см. ниже)](#Раскладка-клавиатуры-и-локализация-консоли)
3. Провести начальную настройку через утилиту `sudo raspi-config`. [(см. ниже)](#Начальная-настройка)
4. Отключить скринсейвер. [(см. ниже)](#Отключение-скринсейвера)
5. Выполнить [скрипт настройки](#Скрипт-настройки).  
   Все последующие пункты с пометкой (sh) не выполнять - они есть в скрипте.
6. [Настроить SSH доступ и локальную сеть.](SSH.md)
7. (sh) Обновить всё что только можно [(см. ниже)](#Обновление)
8. (sh) Установка необходимого минимума программ [(см. ниже)](#Установка-необходимого-минимума-программ)
9. (sh) [Настроить разделы на карте памяти](Disk%20partitioning.md)
10. (sh) [Смонтировать дополнительный раздел](Монтирование%20диска%20или%20флешки.md)
11. [Настроить пользователей системы.](Users.md)
12. [Установить и настроить Samba для создания общей папки.](Samba.md)
13. (нет) Добавить репозиторий **Trixie**. [(см. ниже)](#Добавление-репозитория-Trixie)
14. [Настроить часы реального времени.](RTC.md)
15. [Настроить watchdog.](Watchdog.md)
16. (sh) Отключить Wi-Fi и Bluetooth [(см. ниже)](#Отключение-Wi-Fi-и-Bluetooth)
17. (sh) Применить дополнительные настройки [(см. ниже)](#Дополнительные-настройки)
18. (sh) [Установить и настроить Nginx.](Nginx.md)
19. (sh) [Настроить SSL для Nginx (https).](SSL%20(https).md)
20. [Вручную получить сертификаты SSL (https), если выполнялся скрипт общей настройки.](SSL%20(https).md#Итого)
21. (sh) [Скачать сайт okfilm.com.ua и подключить его к Nginx.](https://github.com/ZatolokinPavel/okfilm_2018)
22. (sh) [Установить Erlang.](Erlang.md)
23. [Скачать и запустить rpi_okfilm_server.](https://github.com/ZatolokinPavel/rpi_okfilm_server)
24. [Скачать и запустить bus_pidgorodne.](https://github.com/ZatolokinPavel/bus_pidgorodne)
25. [Добавить скрипт для сжатия фоток.](Resize%20images.md)
26. [Поднять FTP сервер](FTP.md) для загрузки файлов в общую папку.
27. [Настроить систему проксирования на основе Tor.](TOR%20proxy.md)
28. При желании, [включить порт i2c0 на доп. клеммнике P5](Port%20I2C-0.md)
29. Если надо, установить [Apache, PHP и MySQL](PHP.md)

### Установка операционной системы Raspberry Pi OS Lite
Скачать с [офф. сайта](https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit) и записать на флешку с помощью **Win32DiskImager**.  
Перед запуском нужно отключить расширение файловой системы root на весь размер флешки. Чтобы появилась возможность создать отдельный раздел на флешке для файлообменника "OkFILM диск". Есть два способа:  
_Лучше:_  
С помощью Paragon Partition Manager на винде добавить ещё один небольшой раздел после раздела root. Тогда скрипт не станет расширять раздел root. А этот дополнительный надо будет удалить после.  
_Хуже:_  
На компе открыть файл `/boot/cmdline.txt` и удалить оттуда строчку `quiet init=/usr/lib/raspberrypi-sys-mods/firstboot` (раньше было `quiet init=/usr/lib/raspi-config/init_resize.sh`). Этот файл в винде виден прямо в корне диска `boot` флешки. Удаление этой строчки, в том числе, отключит автоматическое расширение файловой системы root на весь размер флешки. Но и отключит другие твики после первого старта. Какие - не знаю, но вроде генерация SSH ключей в их числе.  

Запустить на малине. Логин/пароль по умолчанию `pi` `raspberry` (устарело).  

Сейчас при первом запуске сразу предложит выбрать раскладку клавиатуры, и задать имя пользователя и пароль.  

Обязательно удалить созданный ранее вспомогательный раздел! Иначе скрипт не разметит правильно разделы.

### Раскладка клавиатуры и локализация консоли
Взято отсюда http://blackdiver.net/it/linux/777  
Заходим в утилиту настройки  
`sudo raspi-config`  
Настраиваем раскладку клавиатуры:
1. Выбрать пункт `5 Localisation Options`
2. Выбрать пункт `L3 Keyboard`
3. Далее ждём загрузки клавиатур и выбираем `Generic 105-key PC (intl.)` (или какая больше подходит)
4. На следующем экране выбрать `Other` для перехода в список всех раскладок
5. Выбрать страну — `Russian`
6. Выбрать русскую раскладку — просто `Russian`
7. Теперь выбираем метод переключения раскладок — предпочитаю `Control+Shift`
8. Клавиша временного переключения на латинскую раскладку — `No temporary switch`
9. Клавиша, которая будет использоваться в качестве AltGr — `The default for keyboard layout`
10. Клавиша, которая будет использоваться в качестве Compose key — `No compose key`
11. Использовать Control+Alt+Backspace для остановки X server — Yes (У меня такого не было).

Смена часового пояса:
1. Выбрать пункт `5 Localisation Options`
2. Выбрать пункт `L2 Timezone`
3. Выбрать область `Europe`
4. Выбрать город `Kiev`

Смена локализации:
1. Выбрать пункт `5 Localisation Options`
2. Выбрать пункт `L1 Locale`
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
`sudo raspi-config` - запустить программу начальной настройки.  
В окне настройки в принципе почти всё понятно. Есть только несколько рекомендаций.
* **1 System Options / S4 Hostname** - установить имя компьютера:  
  `rpi4-home` - для сервера в доме;  
  `rpi3-flat` - для сервера в квартире;  
  `rpi3-media` - для медиацентра в доме;  
  `rpi3-dev` - для прошивок и разработки.  
* **3 Interface Options / I2 SSH** – включить SSH сервер.
* **4 Performance Options / P2 GPU Memory** – распределение памяти Raspberry Pi. Вам необходимо определиться, сколько оперативной памяти вы готовы выделить для графического процессора. При работе в консоли будет достаточно и 16 Мб, а вот для просмотра видео в графической оболочке придется пожертвовать 64-128 Мб. Выбранные значения могут быть только: 16, 32, 64, 128 или 256.
* **5 Localisation Options** – здесь уже всё настроено ранее. Страну для Wi-Fi мне указывать не нужно, так как я отключу Wi-Fi.
* **6 Advanced Options / A1 Expand Filesystem** – увеличение root размера на весь размер карты памяти. Уже не нужно делать.

Остальное не описываю. После завершения настроек нажмите на клавиатуре Ctrl+F, выберите \<Finish\>. Raspberry Pi уйдет на перезагрузку для внесения изменений.

### Установка пароля пользователю 'root' в Raspberry Pi
По умолчанию пароль для рута не установлен. А значит зайти под рутом нельзя вообще. Можно только использовать sudo. И это хорошо. Так что не стоит устанавливать пароль руту.  

### Отключение скринсейвера
При подключении монитора напрямую (не по SSH) если долго не нажимать ничего на клавиатуре, то монитор становится черным. Это мешает и надо отключить. Для этого нужно изменить настройки в файле /etc/kbd/config  
`$ sudo nano /etc/kbd/config`  
```
BLANK_TIME=0
POWERDOWN_TIME=0
BLANK_DPMS=off
LEDS=+num            # заодно включить по умолчанию Num Lock
DO_VCSTIME=yes       # заодно отображать часы в верхнем правом углу консоли
```
`sudo reboot`

### Скрипт настройки
Позволяет автоматически установить и настроить всё, что можно сделать скриптом. Пункты, которые выполнит скрипт, отмечены меткой (sh). Их выполнять не нужно, но они остались для понимания.  
Перед запуском обязательно удалить вспомогательный раздел, если его создавал ранее:  
`sudo fdisk /dev/mmcblk0`, `p`, `d`, `3`, `w`  
Запуск скрипта:  
```shell
cd
wget -O configure_rpi.sh https://git.io/JuDL7
chmod +x ./configure_rpi.sh
./configure_rpi.sh
rm configure_rpi.sh
```

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

### Добавление репозитория Trixie
Этот репозиторий нужно добавить, чтобы из него ставить самые свежие версии пакетов с помощью apt-get. Это репозиторий будущей версии Debian. А текущая версия Debian - Bookworm (12). Посмотреть текущую версию можно командой `lsb_release -a`.  
Итак, в файле `/etc/apt/sources.list` уже есть строчка  
`deb [ arch=armhf ] http://raspbian.raspberrypi.com/raspbian/ bookworm main contrib non-free rpi`  
нужно просто добавить ещё и эту:  
`deb [ arch=armhf ] http://raspbian.raspberrypi.com/raspbian/ trixie main contrib non-free rpi`  
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
`dtoverlay=gpio-fan,gpiopin=26,temp=60000`  
Таким образом, кулер будет включатся ножкой 37 при температуре процессора 60 градусов цельсия. Меньше 60 вроде нельзя ставить.  

О всех остальных devicetree overlay можно почитать здесь: https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README  
