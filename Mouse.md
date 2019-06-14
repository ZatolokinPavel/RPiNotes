# Настройка мыши Logitech  
Эта заметка не относится к Raspberry Pi, но относится к линуксу.  
Будем настраивать дополнительные кнопки на мыше Logitech. Описываю самый простой вариант. А именно, здесь не будет привязки мыши как физитеского устройства к одной точке монтирования. Так что есть вероятность, что со временем номер устройства изменится.  

### Установка xbindkeys  
xbindkeys назначает команду терминала на нажатие кнопки.  
`sudo apt-get install xbindkeys`  
`xbindkeys -d > ~/.xbindkeysrc` - создаём конфигурационный файл  
Теперь запускаем `xev` или `xev | grep button` и нажимаем кнопку мыши. Возможно нажимать кнопку нужно когда указатель находится на белом поле. В консоли увидим что-то вроде `state 0x10, button 9, same_screen YES`.  

### Новый вариант, с использованием xte  
xte is a program that generates fake input using the XTest extension, more reliable than xse.  
`sudo apt-get install xautomation`  
Открываем в редакторе конфиг `nano ~/.xbindkeysrc` и внизу дописываем вот эти строки:  
```
"/usr/bin/xte 'keydown Control_L' 'key Insert' 'keyup Control_L'"
  m:0x10 + b:6

"/usr/bin/xte 'keydown Shift_L' 'key Insert' 'keyup Shift_L'"
  m:0x10 + b:7

"/usr/bin/xte 'keydown Control_L' 'keydown Alt_L' 'key Up' 'keyup Control_L' 'keyup Alt_L'"
  m:0x10 + b:8

"/usr/bin/xte 'keydown Control_L' 'keydown Alt_L' 'key Down' 'keyup Control_L' 'keyup Alt_L'"
  m:0x10 + b:9
```
Тут первая строка - это команда, которую надо выполнить. А вторая - указатель на кнопку. В указателе `m:0x10` - это то что было в `state 0x10`, а `b:9` - это `button 9`.  
Перезагружаем убунту. Или, возможно, хватит просто вот этой команды, чтобы применить конфиг: `xbindkeys -p`.  

### Старый вариант, с использованием xvkbd  
xvkbd выполняет нажатие кнопок на виртуальной клавиатуре по команде из терминала.  
`sudo apt-get install xvkbd`  
Открываем в редакторе конфиг `nano ~/.xbindkeysrc` и внизу дописываем вот эти строки:  
```
"/usr/bin/xvkbd -text "\[Control]\[Insert]""
  m:0x10 + b:6

"/usr/bin/xvkbd -text "\[Shift]\[Insert]""
  m:0x10 + b:7

"/usr/bin/xvkbd -text "\[Control]\[Alt]\[Up]""
  m:0x10 + b:8

"/usr/bin/xvkbd -text "\[Control]\[Alt]\[Down]""
  m:0x10 + b:9
```
Тут первая строка - это команда, которую надо выполнить. А вторая - указатель на кнопку. В указателе `m:0x10` - это то что было в `state 0x10`, а `b:9` - это `button 9`.  
Перезагружаем убунту. Или, возможно, хватит просто вот этой команды, чтобы применить конфиг: `xbindkeys -p`.  

### Прочее  
А ещё вот этой командой можно было получать код кнопки: `xbindkeys -k`. Но он другой. И что-то не вышло.  

https://wiki.archlinux.org/index.php/Xbindkeys_(Русский)  
https://copyraite.blogspot.com/2012/05/ubuntu-1204_14.html  
