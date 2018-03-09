## Электрическое подключение
_Если я правильно понял, интерфейс I2C зависит от питающего напряжения лишь в части подтягивающих резисторов, которые подтягивают обе линии к +U<sub>пит</sub> . Поэтому, если надо к RPi с логикой 3.3 В подключить по I2C модуль с логикой 5 В, достаточно лишь проследить, чтобы все подтягивающие резисторы подключались только к напряжению 3.3 В. Такие резисторы уже есть на RPi, поэтому надо просто выпаять подтягивающие резисторы на модуле, если они подключены к 5 В._  
_Что касается логических уровней, то напряжения 3 В от RPi должно хватить для срабатывания логики на 5 В сторонних модулей._  

## Проверка порта I2C
`sudo atp-get update`  
`sudo apt-get install i2c-tools`  
`sudo i2cdetect -y 1` - поиск адресов подключённых устройств. Здесь `1` - это номер I2C интерфейса. Вообще их два у RPi, по умолчанию доступен первый. Нулевой находится на нераспаянном разъёме и выключен.  
`i2cget -y 1 0x76 0xd0` - считать байт 0xD0 с устройства 0x76  

## Включение порта i2c-0
https://martin-jones.com/2013/08/20/how-to-get-the-second-raspberry-pi-i2c-bus-to-work/  
У Raspberry Pi Model B Revision 2 есть два порта I2C. Из них только второй (i2c-1) выведен на клеммную колодку P1 и включается из raspi-config. Первый (i2c-0) по умолчанию отключён, через raspi-config не включается и может быть выведен на разъём камеры S5 или на нераспаянную клеммную колодку P5. Причём по умолчанию он выведен на разъём камеры S5.  

1. **Припаиваем разъём P5**. Можно припаять точно такие же штырьки, как и на основной клеммной колодке P1, направленные в ту же сторону. Подробное описание тут: https://elinux.org/RPi_Low-level_peripherals  
   Вот картинки на эту тему:  
   <img src="/images/Slanted_P5_header.jpg" height="150">
   <img src="/images/P5_header.jpg" height="150">
   <img src="/images/raspi_P5pinout.png" height="150" title="Вид снизу платы, клеммная колодка P1 слева">
2. **Включаем i2c-0**.  
   Для этого надо прописать строку `dtparam=i2c_vc=on` в файле `/boot/config.txt` и выполнить перезагрузку.  
   > Ещё может понадобится в файл `/boot/cmdline.txt` дописать в конец строки через пробел команду `bcm2708.vc_i2c_override=1`. Но это не точно.  
3. **Устанавливаем библиотеку**, которая поможет нам переключить порт i2c-0 с разъёма камеры S5 на дополнительную клеммную колодку P5. Последнюю версию библиотеки можно найти здесь: http://www.airspayce.com/mikem/bcm2835/ Также, на всякий случай, я сохраню копию [у себя в репозитории](libs/bcm2835-1.55.tar.gz). Команды для установки:
   ```bash
   wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.55.tar.gz
   tar xzvf bcm2835-1.52.tar.gz
   cd bcm2835-1.52
   ./configure
   make
   sudo make check
   sudo make install
   ```  
4. **Готовим программу для переключения порта i2c-0**.  
   Для этого где-нибудь в домашней папке нужно создать файл [`i2c0.c`](libs/i2c0.c) с таким содержимым:  
   ```c
   #include <bcm2835.h> 

   #define BCM2835_GPIO_FSEL_INPT 0 
   #define BCM2835_GPIO_FSEL_ALT0 4 

   void main() {
       bcm2835_init(); 
       bcm2835_gpio_fsel(0, BCM2835_GPIO_FSEL_INPT); 
       bcm2835_gpio_fsel(1, BCM2835_GPIO_FSEL_INPT); 
       bcm2835_gpio_fsel(28, BCM2835_GPIO_FSEL_INPT); 
       bcm2835_gpio_fsel(29, BCM2835_GPIO_FSEL_INPT); 

       bcm2835_gpio_fsel(28, BCM2835_GPIO_FSEL_ALT0); 
       bcm2835_gpio_set_pud(28, BCM2835_GPIO_PUD_UP); 
       bcm2835_gpio_fsel(29, BCM2835_GPIO_FSEL_ALT0); 
       bcm2835_gpio_set_pud(29, BCM2835_GPIO_PUD_UP); 
   }
   ```
   It initialises the library, sets GPIO 0 and 1 as normal inputs (thus disabling their I2C function) and enables GPIO 28 and 29 as alternate function 0 (I2C bus), with pullup enabled.  
   Далее нужно скомпилить его следующей командой  
   `cc i2c0.c -o i2c0_remap -lbcm2835`  
   и можно пробовать запускать: `./i2c0_remap` (или, если надо, `sudo ./i2c0_remap`)  
5. **Если нужно, добавляем переключение порта i2c-0 в автозагрузку**.  
   Для этого копируем файл `i2c0_remap` в каталог `/bin` и добавляем в файл `/etc/rc.local` до завершающей строки строки `exit 0` следующую строку:  
   `/bin/i2c0_remap # Remap i2c-0 port from S5 connector to P5 connector`  
