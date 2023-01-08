---
layout: til_post
title:  "Responsive Navbar with Tailwind & Stimulus JS"
categories: til
disq_id: til-98
---

![screenshot](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2022/tailwind-stimulous-navbar-lg.png)
![screenshot](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2022/tailwind-stimulus-navbar.png)


```html
<!-- app/views/layouts/_navbar.html.erb -->

<header
  class="bg-gray-500 sm:flex sm:justify-between sm:px-4 sm:py-1 sm:items-center"
  data-controller="navbar" data-navbar-state-value="false">
  <div class="flex justify-between px-4 py-1 sm:p-0 items-center">
    <div class="font-bold text-xl font-mono text-gray-200">
      <span class="text-orange-400">Dev</span>Prof
    </div>
    <div class="sm:hidden">
      <button class="text-orange-400 focus:text-white focus:outline-none hover:text-white block"
        type="button"
        data-action="click->navbar#toggle" >
        <span class="sr-only">Open main menu</span>
        <svg class="h-8 w-8 fill-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
          <path data-navbar-target="x"    stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" class="hidden" />
          <path data-navbar-target="bars" stroke-linecap="round" stroke-linejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
        </svg>
      </button>
    </div>
  </div>
  <div class="hidden sm:flex px-2 pt-2 pb-4 sm:pb-2" data-navbar-target="menu">
    <a href="/" class="block text-gray-200 font-semibold hover:bg-gray-800 rounded px-2 py-1">Home</a>
    <a href="/" class="block text-gray-200 font-semibold hover:bg-gray-800 rounded px-2 py-1 mt-1 sm:mt-0 sm:ml-2">Developers</a>
    <a href="/" class="block text-gray-200 font-semibold hover:bg-gray-800 rounded px-2 py-1 mt-1 sm:mt-0 sm:ml-2">Cool Stuff</a>
  </div>
</header>
```


```javascript
/* app/javascript/controllers/navbar_controller.js */

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values  = { state: Boolean }
  static targets = [ "menu", "x", "bars" ]

  connect() {
    console.log(this.stateValue)
  }

  toggle() {
    this.stateValue = !this.stateValue

    if (this.stateValue) {
      this.openMenu()
      this.xTarget.classList.remove("hidden")
      this.barsTarget.classList.add("hidden")
    } else {
      this.closeMenu()
      this.xTarget.classList.add("hidden")
      this.barsTarget.classList.remove("hidden")
    }
  }

  openMenu() {
    this.menuTarget.classList.remove("hidden");
  }

  closeMenu() {
    this.menuTarget.classList.add("hidden");
  }
}
```


### Sources

* <https://www.youtube.com/watch?v=ZT5vwF6Ooig>
* <https://stimulus.hotwired.dev/handbook/managing-state>
