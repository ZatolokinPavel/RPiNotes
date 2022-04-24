# Добавление нового раздела на флешке
Имеет смысл для файлообменника "OkFILM диск" создать отдельный раздел на флешке. Чтобы его можно было забить полностью файлами,
но при этом на системном разделе не закончилось место.  
Размер системного раздела предлагаю сделать:  
максимум - если флешка размером 8 GB (то есть, только один раздел);  
5 GB - если флешка размером 32 GB;  
16 GB -  если флешка размером 128 GB и больше.  

Посмотреть текущую структуру диска:  
`sudo fdisk -l /dev/mmcblk0`  

## Изменение размера root раздела
### Вариант 1 - если root раздел ещё не расширен на всю флешку
Так как перед первым стартом системы я отключил скрипт, расширяющий корневой раздел на всю флешку, то на данный момент на флешке `/dev/mmcblk0` есть два раздела:  
1 - 273MB fat32  
2 - 1745MB ext4  
Это то, что было заложено в образе Raspberry Pi OS Lite изначально.  

Увеличиваем root раздел до отметки 17180MB + 273MB
```
sudo parted /dev/mmcblk0
(parted) resizepart 2 17453MB
(parted) print
(parted) quit
```

Расширяем root до размера увеличенного раздела  
`sudo resize2fs /dev/mmcblk0p2`  

### Вариант 2 - если root раздел уже занимает всю флешку
Уменьшить root раздел на запущенной системе не получится. Нужно менять раздел на другом компьютере.  
Для Windows можно использовать https://www.paragon-software.com/free/pm-express/  
К сожалению, Acronis не поддерживает файловую систему ext4.  

Итого, нужно выключить Raspberry Pi, вынуть sd карту, вставить её в комп и там с помощью Paragon Partition Manager уменьшить раздел.  
Новый размер раздела - 16GB.  

Теперь вставляем sd-карту в Raspberry Pi и запускаем систему. Снова смотрим текущую структуру диска:  
`sudo fdisk -l /dev/mmcblk0`  
Результат будет примерно таким:  
```
pi@rpi4-home:~ $ sudo fdisk -l /dev/mmcblk0
Disk /dev/mmcblk0: 119,38 GiB, 128177930240 bytes, 250347520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x94172dc9

Device         Boot  Start      End  Sectors  Size Id Type
/dev/mmcblk0p1        8192   532479   524288  256M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      532480 34086911 33554432   16G 83 Linux
```

## Создание нового раздела для файлообменника  
`sudo fdisk /dev/mmcblk0`  
`p` - посмотреть текущее состояние.  
`n`, `p`, `3` - создать новый primary раздел. Первым указать сектор, следующий после последнего сектора
предыдущего раздела (в примере это 34086912). Последний - оставить по умолчанию максимально возможный.  
`w` - записать вновь созданную структуру разделов.  

Форматируем в ext4 (как и рутовый раздел) с меткой диска 'okdisk' устройство /dev/mmcblk0p3  
`sudo mkfs.ext4 -L okdisk /dev/mmcblk0p3`  

## Раздел создан, теперь нужно настроить его монтирование.  
В принципе, монтирование раздела описано тут:
[монтирование флешки](https://github.com/ZatolokinPavel/RPiNotes/blob/master/USB%20%D1%84%D0%BB%D0%B5%D1%88%D0%BA%D0%B0.md).
Приведу те же инструкции, но с поправкой на диск.  

Итак, сначала создаём папку `/mnt/okdisk/`  
Затем, создаём файл `/etc/systemd/system/mnt-okdisk.mount`  
```
[Unit]
Description=OkFILM global share
[Mount]
What=/dev/mmcblk0p3
Where=/mnt/okdisk
Type=ext4
Options=defaults
DirectoryMode=0755
[Install]
WantedBy=multi-user.target
```
и файл автомонтирования `/etc/systemd/system/mnt-okdisk.automount`  
```
[Unit]
Description=OkFILM global share
[Automount]
Where=/mnt/okdisk
[Install]
WantedBy=multi-user.target
```
Теперь эти файлы нужно подключить:  
`sudo systemctl enable mnt-okdisk.mount`  
`sudo systemctl enable mnt-okdisk.automount`  
Всё готово.
