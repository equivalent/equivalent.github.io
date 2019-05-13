---
layout: til_post
title: "Visualized Desktop Workspace flow in Manjaro linux 18 - XFCE"
categories: til
disq_id: til-61
---


This article is manual how to set up [Manjaro linux 18 - XFCE](https://manjaro.org/download/xfce/) so it works with   [Visualized Workspaces Workflow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html) concept

> If you have no idea what that is please read [this article](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html)  to understand what it's about and why the steps bellow are necessary  

## Step 1 - add more workspaces

 Go to:

```
Menu > workspaces 
```

Increment number of workspaces

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/manjaro-step1-add-workspaces.png)

## Step 2  - add  switch to window num. shortcuts

```
Menu > Window Manager > keyboard
```

Add shortcut that you like. For example:

```
Move Window to workspace 1        Super + Ctrl + 1
Move Window to workspace 2        Super + Ctrl + 2
Move Window to workspace 3        Super + Ctrl + 3
Move Window to workspace 4        Super + Ctrl + 5
Move Window to workspace 5        Super + Ctrl + 5
Move Window to workspace 6        Super + Ctrl + 6

Workspace 1                       Super + 1
Workspace 2                       Super + 2
Workspace 3                       Super + 3
Workspace 4                       Super + 4
Workspace 5                       Super + 5
Workspace 6                       Super + 6

```

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/manjaro-step-2-add-window-shortcut--witch-workspace.png)

## Step 3 - remove Super mapping (Optional)

> This step is optional if you don't use "Super" button (Windows button) for your Workspace switch

In order to be able to map "Super + 1" combination for workspace switch  we need to remove default mapping for Menu dialog lunch


```
Menu > Keyboard > Application Shortcuts
```

...find shortcut "L Super" (`xfc4-popup-whiskermenu` by default) and map it to something else (e.g. `Super + Space` or remove it

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/manjaro-step3-remove-super-shortcut.png)


## Step 4 - remove mapping for "terminal pop-up" (Optional)

When you pres "Ctrl+Alt+T" in Manjaro. By default you get anoying Terminal Popup
that works terrible for [Visualized Workspaces Flow](https://blog.eq8.eu/article/visualized-desktop-workspaces-flow.html)

In order to replace this shortuct with real Terminal bounded to current
Workspace you can do following


Go to 

```
Menu > Keyboard > Application Shortcuts
```

and Remove existing mapping `alt+ctrl+T` (`xfce4-terminal-popup`)

add new mapping `alt+ctrl+T`  for `xfce4-terminal`

![](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/manjaro-step-4-replace-terminal-popup-shortcut.png)
