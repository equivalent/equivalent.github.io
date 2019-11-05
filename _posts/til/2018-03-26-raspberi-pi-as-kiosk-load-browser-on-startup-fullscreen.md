---
layout: til_post
title:  "Raspberi PI as kiosk (load browser on startup fullscreen)"
categories: til
disq_id: til-46
---

...or how to start Midori browser in fullscreen on raspberian



**IMPORTANT NOTE!!!**

> update 2019-11-05: I've recently tried steps bellow and thy don't work.
> Not only that but it may cause your Raspberian Desktop not to load. I don't know why and don't have time to investigate.

> Steps worked year ago but with recent Raspberian image some options
> seems not to load properly.

> Anyway I'm keeping this article for historic puprpose and older
> Raspberian image versions but I recommend not to follow these steps.



This TIL note is basically just a mirror of
<http://www.raspberry-projects.com/pi/pi-operating-systems/raspbian/gui/auto-run-browser-on-startup>
but there were some fixes based on
<https://raspberrypi.stackexchange.com/questions/42633/raspberry-pi-autostart-of-lxde-does-not-work>


#### Step 1 - boot to Desktop autologin


```ruby
sudo raspi-config
```

and choose

```
3. Boot Options -> B1. Descktop / CLI -> B4 Desktop Autologin
```

#### Step 2 install Midori Browser

install `midori` browser 

> yes there is chrome or Firefox but it seems this works only on Midori for me

`sudo apt install midori`


#### Step 3 config lxde autostart

Add at the bottom of the file `~/.config/lxsession/LXDE-pi/autostart`


This

```
# Auto run the browser
@xset s off
@xset -dpms
@xset s noblank
@midori -e Fullscreen -a http://google.com
```

> If you need to refresh the page midori supports `-i` option to specify
> number of secconds of inactivity to refresh the page `midori -e Fullscreen -a http://google.com -i 5`


**note:**

If this doesn't work try to do the same to this file:

```
sudo vim /etc/xdg/lxsession/LXDE/autostart 
```

#### step 4 restart raspberi PI

`sudo shutdown -r now`


all should just work
