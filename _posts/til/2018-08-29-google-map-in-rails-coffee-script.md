---
layout: til_post
title:  "Google Maps in Rails with Coffee Script"
categories: til
disq_id: til-54
---

## First generate Google API token

1. go to <https://console.cloud.google.com/google/maps-apis/overview>
2. create a project / open a porject from top menu
3. generate API key for "Maps JavaScript API"
4. in the "credentials" section for the key in "Application restrictions" tab  set "Application
   restriction" to "HTTP referrers" and add lits of allowed websites
   (E.g. https://www.mywebsite.com, localhost:4567)
5. in the "credentials" section for the key in "API Restriction" tab  set 
   restriction to "Maps JavaScript API"
6. in the "Quotas" section for the key set some reasonable quotas so you
   wont get charged lot of $$$

> note: From Summer 2018 you need to fill in billing details for google
> developer console - [source](https://developers.google.com/maps/documentation/javascript/usage-and-billing) (in case your website gets hit miliont times google will charge you).

## One map

```css
// app/assets/stylesheets/application.css

#map {
  min-height: 400px;
  width: 100%;
}
```


```js
// app/assets/javascript/application.js
// ...
//= require my_maps
// ...
```

```coffee
# app/assets/javascript/my_maps.coffee
window.initMap = ->
  if (document.getElementById('map1'))
    map_element = $('#map')
    location =
      lat: map_element.data('lat')
      lng: map_element.data('lng')
    map = new (google.maps.Map)(document.getElementById('map1'),
      zoom: 16
      center: location)
    marker = new (google.maps.Marker)(
      position: location
      map: map)
```

#### Without turbolinks:

> replace xxxxxxxxxxxx with your API Key

```html
<!-- app/views/layouts/application.html.erb -->
<html>
  <head>
    <%= stylesheet_link_tag    'application', media: 'all' %>
  </head>

  <body>
    <div id="map" data-lat="49.268661" data-lng="20.249441"></div>

    <script async defer src="https://maps.googleapis.com/maps/api/js?key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&callback=initMap" type="text/javascript"></script>
    <%= javascript_include_tag 'application' %>
  </body>
 </html>
```

> the `&callback=initMap` part of script tag src will ensure the function is
> called

#### With turbolinks:

> I'm not 100% sure this is the righth way, there may be a better way
> out there

```html
<!-- app/views/layouts/application.html.erb -->
<html>
  <head>
    <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    <%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", async: true, 'data-turbolinks-eval': false %>
    <%= javascript_include_tag 'application', 'data-turbolinks-track': 'reload' %>
  </head>

  <body>
    <div id="map" data-lat="49.268661" data-lng="20.249441"></div>
  </body>
<html>
```

```coffee
# app/assets/javascript/my_maps.coffee

# ...

$(document).on "turbolinks:load", ->
  initMap()
```


## Multiple Maps

Just change the `initMap` to:

```coffee
# app/assets/javascript/my_maps.coffee

window.initMap = ->
  maps = document.getElementsByClassName('maps')
  i = 0
  while i < maps.length
    mapId = document.getElementById(maps[i].id)
    lat = mapId.getAttribute('data-lat')
    lng = mapId.getAttribute('data-lng')
    # Create new Google Map object for single canvas
    map = new (google.maps.Map)(mapId,
      zoom: 15
      center: new (google.maps.LatLng)(lat, lng)
      mapTypeId: 'roadmap'
      mapTypeControl: true
      zoomControlOptions: position: google.maps.ControlPosition.RIGHT_TOP)
    # Create new Google Marker object for new map
    marker = new (google.maps.Marker)(
      position: new (google.maps.LatLng)(parseFloat(lat), parseFloat(lng))
      map: map)
    i++
  return
```

> stolen from <https://stackoverflow.com/a/46981340/473040>

And be sure to add css class "maps" to the divs and make sure the id is
different !

```html
<div id="map1" class="maps" data-lat="49.268661" data-lng="20.249441"></div>
<div id="map2" class="maps" data-lat="49.2716104" data-lng="20.2217018"></div>
<div id="map3" class="maps" data-lat="49.2716104" data-lng="20.2217018"></div>
```

And make sure CSS will recognize class "maps" instead of hard id:

```css
// app/assets/stylesheets/application.css

// we changed #map to .maps
.maps {
  min-height: 400px;
  width: 100%;
}
```



