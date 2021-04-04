---
layout: til_post
title: "Visualized Desktop Workspace flow in Ubuntu 18.04"
categories: til
disq_id: til-67
---


This article is manual how to set up [Ubuntu 18.04](https://ubuntu.com/download/desktop) so it works with   [Visualized Workspaces Workflow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html) concept.
This setup should probably work also for Ubuntu with manually installed XFCE


> Visualized Workspaces flow is a setup of workspaces in Desktop Environment for maximum productivity.  Please read more in [this article](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html) to understand why the steps bellow are necessary



## install tweak tools

```
sudo apt install gnome-tweak-tool

```



Once installed change workspaces to static and change number of workspaces to 6

```
Gnome Tweaks Tool > workspaces > StaticWorkspaces
Gnome Tweaks Tool > workspaces > Numpber of Workspaces = 6
```

* in workspaces section eneble static workspaces and set them to 6

> stolen from <https://www.youtube.com/watch?v=qTsPLCJdbJw> 

## set up keyborad shortcuts for workspace switch


to read current value of keyboard shortcut

```
dconf read /org/gnome/desktop/wm/keybindings/switch-to-workspace-1

['<Primary>1']

dconf read /org/gnome/desktop/wm/keybindings/move-to-workspace-1

['<Alt><Primary>1']
```

> note in Ubuntu it super hard to map anything on the Super button e.g. issue with `['<Super>0']` that's why I switch to Ctrl => `<Primary>`

To write new keyboard shortcut:

```
# left hand
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-1 "['<Primary>1']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-2 "['<Primary>2']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-3 "['<Primary>3']"

dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-4 "['<Primary>8']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-5 "['<Primary>9']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-6 "['<Primary>0']"

dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-1 "['<Alt><Primary>1']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-2 "['<Alt><Primary>2']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-3 "['<Alt><Primary>3']"

dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-4 "['<Alt><Primary>8']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-5 "['<Alt><Primary>9']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-6 "['<Alt><Primary>0']"

```

> note sometimes it take a while for this config to apply. Try restart


## when alt+tab only switch current workspace windows

```
gsettings set org.gnome.shell.app-switcher current-workspace-only true
```

## when alt+tab disable grouping of windows

<https://askubuntu.com/questions/1036248/how-to-separate-opened-windows-in-alttab-switcher-in-ubuntu-18-04>

```
 settings > devices > keyboard 

# under Navigation keyboard shortcuts find  `Switch Windows` and set that to `alt+tab` it will replace `Switch Application`  shortcut (which is the grouping)
```


## move Ubuntu Launcher to bottom (Dock bottom)

```
> settings > Dock > position on screen bottom
```

## other setting


There are some interesting tips in this video <https://www.youtube.com/watch?v=qTsPLCJdbJw> you may want to consider
