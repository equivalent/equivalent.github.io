---
layout: til_post
title: "Visualized Desktop Workspace flow in Xubuntu 18.04 - XFCE"
categories: til
disq_id: til-62
---


This article is manual how to set up [Xubuntu](https://xubuntu.org/) so it works with   [Visualized Workspaces Workflow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html) concept.
This setup should probably work also for Ubuntu with manually installed XFCE


> Visualized Workspaces flow is a setup of workspaces in Desktop Environment for maximum productivity.  Please read more in [this article](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html) to understand why the steps bellow are necessary

## Step 1 - add more workspaces

 Go to:

```
Menu > workspaces 
```

Increment number of workspaces

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/xubuntu-step1-set-workspaces.png)

## Step 2  - add  switch to workspaces number shortcuts

```
Menu > Window Manager > keyboard
```

Add shortcut that you like. For example:

```
Workspace 1                       Super + 1
Workspace 2                       Super + 2
Workspace 3                       Super + 3
Workspace 4                       Super + 4
Workspace 5                       Super + 5
Workspace 6                       Super + 6

Move Window to workspace 1        Super + ALT + 1
Move Window to workspace 2        Super + ALT + 2
Move Window to workspace 3        Super + ALT + 3
Move Window to workspace 4        Super + ALT + 5
Move Window to workspace 5        Super + ALT + 5
Move Window to workspace 6        Super + ALT + 6
```

> by "Super" I mean the Left hand  "Windows" button or sometimes
> referenced as `SuperL`

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/xubuntu-step2-workpsace-shortcuts.png)


## Other notes


Xubuntu is really friendly to [Visualized desktop workspaces flow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html)
so from this point you should be good to go.

However here are some of mine optional recommendations for better
experience


#### Set menu dialog

By default the menu dialog will pop-up when you press `ctrl + esc`. I
find it bit more productive if the shortcut is `ctrl + Super` (ctrl + left
windows button) or `Super + Space`


```
Menu > Keyboard > Application Shortcuts
```

Add `xfce4-popup-whiskermenu` and set it to `ctrl + super`.


#### Stop browser window from switching workspace

By default in Xubuntu when you clikt on a link (E.g. in Slack) browser
opened in other workspace will move to curret workspace. This violates
the Visualized  workspaces flow.

To disable this:

```
Menu > Keyboard > Window Manager Tweaks > Focus Tab > 

set: "When a window raises itself"
to: "Do nothing"
```

![](https://i.stack.imgur.com/Dn4Tj.png)

source: 

* <https://unix.stackexchange.com/questions/97918/stop-browser-window-from-switching-workspace-and-getting-focus-when-opening-a-li>



## Related articles

* [Visualized desktop workspaces flow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html)
* [Visualized Desktop Workspace flow in Cinnamon](https://blog.eq8.eu/til/cinnamon-workspaces.html)
* [Visualized Desktop Workspace flow in Manjaro linux 18 - XFCE](https://blog.eq8.eu/til/xfce-workspaces.html)

## Discussion

* [Reddit](https://www.reddit.com/r/xubuntu/comments/boiwii/visualized_desktop_workspace_flow_in_xubuntu_1804/)
