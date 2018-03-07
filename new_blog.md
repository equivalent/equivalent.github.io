---
layout: page
title: Why the new blog ?
short_title: Why new blog?
permalink: /why-new-blog/
---

I'm in a process of transferring old blog `http://www.eq8.eu/blogs` to
new blog located at `https://blog.eq8.eu`.

I promise that this transition will go smoothly and:

* all the old blog/talk/TILs links will be properly 301 redirected to new location
* all the discussion stay alive (although Disqus comment section may be
  disabled for few days during the process of transformation)
* I will update all old links that I can (like Reddit discussions, SO answers) so
  they point to new location

> Trust me it's painful and slow process, but I'll get this right. No
> links will be broken.

## Why the transformation

The old blog was built with Ruby on Rails application hosted under Heroku.
This was done way back in the days when Heroku was free. Articles were
hosted on [Github Repo](https://github.com/equivalent/scrapbook2/blob/master/archive/) and were
pulled, parsed and cached in this Rails application.

The new blog is built with [Jekyll](https://jekyllrb.com/) hosted for
free on [Github Pages](https://pages.github.com). All the articles
are located directly within the Jekyll project
[repo](https://github.com/equivalent/equivalent.github.io/tree/master/_posts)

Now reason why I switch to Jekyll is not because I want to save $7 a
month (although it's a nice side effect) but because I want to be able to be able
to post new articles and typo changes more often.


I was quite proud of the original Rails + GH Repo functionality in the beginning. But more
articles I've published more the pain with maintaining them came. Each time
I needed to drop the cache and push to 2 different respositories. That
may not sound like a big deal but I found myself in a position where I
rather ignored reported typos rather than fix them.

## What does this means ?

It means that I'll be posting more articles, more often providing better
support. Old links will be properly redirected appropriately with 301 to  new
locations and old discussions will be moved as well.

You (the reader) will only benefit from this change <3

Keep on reading ;) 

And please let me know if you spot something wrong
by emailing me: `equivalent@eq8.eu`

Thank you
