# VLAN на роутерах

## OpenWrt
Приблизительная инструкция куда смотреть, что настраивать.  
Вообще настраиваем VLAN на вспомогательном устройстве. То есть, это устройство будет работать с несколькими VLAN, которые приходят от основного роутера.  
`Network` > `Interfaces` > `Devices` > выбираем bridge (стандартно `br-lan`) > `Configure...` > `Bridge VLAN Filtering` tab
Тут устанавливаем, какие VLAN ID будут доступны на каких портах и в каком виде (Tagged, Untagged).  

Add the Other VLAN Interfaces
We need to add the other VLANs as interfaces on this AP.  
1. On the Interfaces tab, click `Add New Interface`
2. On the window that pops-up, give your new interface a meaningful Name. I called my
VLAN 20 Interface “Media”, as it will be used for my media devices like Roku, Apple TV,
etc.
3. Select `DHCP client` for the Protocol field.
4. Select your second VLAN as the Device. In my case it was "br-lan.20".
5. Click `Create Interface`.

Next, you'll be taken to the same screen as you saw when Editing the 'lan' interface.
1. Check all.
2. Set up static IPv4 Address for this VLAN, if it is not DHCP.
4. Click ‘Save’

Repeat the above steps for as many VLANs as you are creating.  
Если по какому-то VLAN интерфейс роутера не должен быть доступен (гостевой VLAN), тогда устанавливаем `Protocol: Unmanaged`  

WiFi  
`Network` > `Wireless`  
Для каждой WiFi сети `Interface Configuration` > `General Setup` > `Network` устанавливаем необходимый VLAN интерфейс.  
Дополнительно `Interface Configuration` > `Advanced Settings` > `Interface name` можно прописать статичное имя в виде `phy0-ap0` с разными цифрами.
Это пригодится для настройки `LED Configuration`, так как иначе имя интерфейса может меняться при перезагрузке.  

## Попытка настроить VLAN на роутере tp-link TL-WR840N v4.0 с прошивкой Padavan  
Цель - на одном роутере развернуть несколько независимых локальных сетей.  
Придётся все делать через консоль. В веб-интерфейсе этого всего нет.  

Смотрим имеющиеся интерфейсы:  
```
/ # ls /proc/net/vlan/
config  eth2.1  eth2.2
```
Добавляем новый, пробный vlan. После перезагрузки он пропадёт.  
`vconfig add eth2 7`  
Повесим ip-адрес на новый интерфейс "eth2.7"  
`ifconfig eth2.7 192.168.7.1 netmask 255.255.255.0 up`  

Ииии... Пока всё. Не знаю, что это дало.  
