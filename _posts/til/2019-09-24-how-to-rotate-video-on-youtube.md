---
layout: til_post
title:  "How to rotate video on Youtube"
categories: til
disq_id: til-69
---

Youtube "rotate video" feature was not removed just hidden in Youtube studio Clasic.

I'll show you
how you can access it but you must have basic understanding of what is
"Browser element inspector" and how HTML works otherwise what I'll write
here does not make sense.


> If you have no idea what I'm talking about you can watch [this video](https://www.youtube.com/watch?v=DFAuLyaPmxg) better explaining 

Steps I'm describing  will work with Google Chrome or Firefox.


* step 1 upload your video (unrotated)
* step 2 go to Youtube studio (beta) `https://studio.youtube.com`
* step 3 in side menu click `Creator Studio Clasic` (It's located at bottom left part of the website). If asked `why you need to go back to Creator Studio Clasic` sellect anything.
* step 4 once in The Youtube clasic interface click on the video `edit`
* step 5 click on `Enhancements`
* step 6 next to `Trim` button **right click** with your mouse and select `inspect` or `inspect element`

Now here is wher your HTML skills will come handy.
You need to locate `<div class="enhance-effect" id="enhance-rotate-buttons" hidden="true">`
and remove the `hidden` attribute so you end up with `<div class="enhance-effect" id="enhance-rotate-buttons">`


```html
<div id="enhance-trim-rotate">
  ...
  <div class="enhance-effect" id="enhance-rotate-buttons" hidden="true">
    ...
  </div>
</div>
```


to

```html
<div id="enhance-trim-rotate">
  ...
  <div class="enhance-effect" id="enhance-rotate-buttons" >
    ...
  </div>
</div>
```

![How to rotate video in Youtube](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/youtube-rotate-video-1.png)
![How to rotate video in Youtube result](https://raw.githubusercontent.com/equivalent/equivalent.github.io/master/assets/2019/youtube-rotate-video-2.png)




So now just click on the rotation buttons, save video and boom done.


### Source

* [how to rotate youtube video](https://www.youtube.com/watch?v=DFAuLyaPmxg)

### Discusion

