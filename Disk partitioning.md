# Добавление нового раздела на флешке
Если флешка большая (например 128GB) и на ней будет размещён файлообменник "OkFILM диск", то имеет смысл
для файлообменника создать отдельный раздел на флешке. Чтобы его можно было забить полностью файлами,
но при этом на системном разделе не закончилось место.  

Посмотреть текущую структуру диска:  
`sudo fdisk -l /dev/mmcblk0`  

Изменить root раздел на запущенной системе не получится. Нужно менять раздел на другом компьютере.  
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
