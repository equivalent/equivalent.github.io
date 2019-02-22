---
layout: til_post
title:  "Cinnamon workspaces for productivity development"
categories: til
disq_id: til-57
---



## step 1  - increase the number of workspaces

default numper of workspaces in Cinnamon is 4 (I need 6)

```bash
gsettings set org.cinnamon.desktop.wm.preferences num-workspaces 6
```


##  step 2 - Shortucuts for switching workspaces

```
Menu > Keyboard > Shortcuts Tab > Workspaces > Direct Navigation
```

Set

```
"Switch to workspace 1"   to be "Super+1"
"Switch to workspace 2"   to be "Super+2"
"Switch to workspace 3"   to be "Super+3"
"Switch to workspace 4"   to be "Super+8"
"Switch to workspace 5"   to be "Super+9"
"Switch to workspace 6"   to be "Super+0"
```


##  step 3 - Shortucuts for Moving window to workspaces

```
Menu > Keyboard > Shortcuts Tab > Windows > Inter-workspace
```

Set

```
"Move window to workspace 1"   to be "Alt+Super+1"
"Move window to workspace 2"   to be "Alt+Super+2"
"Move window to workspace 3"   to be "Alt+Super+3"
"Move window to workspace 4"   to be "Alt+Super+8"
"Move window to workspace 5"   to be "Alt+Super+9"
"Move window to workspace 6"   to be "Alt+Super+0"
```

## (Optional) Disable workspace animation


```
Menu > Workspaces > OSD tab > enable workspace OSD > off
```

```
Menu > Effects > Window effects >  off
```




## Install Cinamon on Ubuntu 18.04

```bash
sudo add-apt-repository ppa:embrosyn/cinnamon
sudo apt-get update
sudo apt install cinnamon
```
