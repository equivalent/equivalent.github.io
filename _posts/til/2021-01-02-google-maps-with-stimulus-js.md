---
layout: til_post
title:  "Embed Google Maps JS with Stimulus JS"
categories: til
disq_id: til-85
---

```js
// app/javascript/controllers/map_controller.js
export default class extends Controller {
  static targets = [ 'map' ]

  connect () {
    if(this.hasMapTarget) {
      let lat = parseFloat(this.mapTarget.dataset.lat)
      let lon = parseFloat(this.mapTarget.dataset.lon)
      let location = { lat: lat, lng: lon };

      var map = new (google.maps.Map)(this.mapTarget, { zoom: 10, center: location });
      var marker = new (google.maps.Marker)({position: location, map});
    }
  }
}
```

```css
/* app/assets/stylesheets/application.css

.map {
  height: 250px;
}

```


```html
<!-- app/views/layouts/application.html.erb -->
<html>
  <body>
    <div data-controller="map">
      <div class="map" data-target="map.map" data-lon="18.0791" data-lat="48.3268"></div>
    </div>

    <%= javascript_include_tag google_maps_script_src, async: true %>
  </body>
</html>

```

```ruby
# app/helpers/map_helper.rb
module MapHelper
  def google_maps_script_src
    "https://maps.googleapis.com/maps/api/js?key=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&v=3.42.8"
  end
end
```
