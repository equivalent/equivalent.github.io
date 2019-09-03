---
layout: til_post
title:  "What page should the pagination start from ?"
categories: til
disq_id: til-68
---


Recently I had discussion: Should the pagination start from `page 1` or
from `page 0` ?


## Pagination starting from page 1 - Book-like pagination

It's similar to numbering a book pages. First page with content is page 1.

I tell you the book has 4 pages it mean the page 4 has last
page with the content. So you naturally assume first page of the book is 1 and
last page of book is 4


```
e.g. given I have 32 items with limit 10

page 1 - first set of data   1 - 10
page 2 - first set of data  11 - 20
page 3 - first set of data  21 - 30
page 4 - first set of data  31, 32

```

This way API can return total pages / what is the last page easily.


First page:

```
get /student/123/works?limit=10`
# ...or
get /student/123/works?limit=10&page=1`
```

```json
{
  "student": {
    "name": "Tomi",
    "works": {
       "data": [
          { title: "work 1" },
          { title: "work 2" },
          { title: "work 3" },
          { title: "work 4" },
          { title: "work 5" },
          { title: "work 6" },
          { title: "work 7" },
          { title: "work 8" },
          { title: "work 9" },
          { title: "work 10" }
        ]
       "limit": 10,
       "current_page": 1,
       "first_page": 1,
       "last_page": 4
    }
 }
}
```

Last page:

`get /student/123/works?limit=10&page=4`

```json
{
  "student": {
    "name": "Tomi",
    "works": {
       "data": [
          { title: "work 31" },
          { title: "work 32" },
        ]
       "limit": 10,
       "current_page": 4,
       "first_page": 1,
       "last_page": 4
    }
 }
}
```


Due to fact that `last page` is the same number as `total number` of pages 
it's easy to calculate how many elements you may receive. If you know
the last page is `4` and you are limiting results to `10` so you may
end up with up to `40` elements because `10 * 4`


> Simmilar pagination numbering is based in other solution like
> [Will paginate](https://github.com/mislav/will_paginate) or [kaminari](https://github.com/kaminari/kaminari)
> where first page is 1


## Pagination starting from page 0 - Array-like

So one other idea may to implement pagination so imitating how Array works.
This means  first element is page 0:

```
e.g. given I have 32 items with limit 10

page 0 - first set of data   1 - 10
page 1 - first set of data  11 - 20
page 2 - first set of data  21 - 30
page 3 - first set of data  31, 32
```

First page:

```
get /student/123/works?limit=10`
# ...or
get /student/123/works?limit=10&page=0`
```


```json
{
  "student": {
    "name": "Tomi",
    "works": {
       "data": [
          { title: "work 1" },
          { title: "work 2" },
          { title: "work 3" },
          { title: "work 4" },
          { title: "work 5" },
          { title: "work 6" },
          { title: "work 7" },
          { title: "work 8" },
          { title: "work 9" },
          { title: "work 10" }
        ]
       "limit": 10,
       "current_page": 0,
       "first_page": 0,
       "last_page": 3
    }
 }
}
```

last page:


`get /student/123/works?limit=10&page=3`

```json
{
  "student": {
    "name": "Tomi",
    "works": {
       "data": [
          { title: "work 31" },
          { title: "work 32" },
        ]
       "limit": 10,
       "current_page": 3,
       "first_page": 0,
       "last_page": 3
    }
 }
}
```


On technical side this works but at the same time you look at `&page=3`
you would expect it's 3rd page but really it's 4th page.

This mean `last page` is not the same as `total number` of pages.

This will start being problem once you consider Math: Because last page is `3` and we limit by `10` that means `10 * 3` = 30 elements ?
No it's up to 40 elements `10 * 4` (4 pages in total). This may be bit confusing for clients using your API

## Conclusion

My point is: do yourself a favor, Start paginating from page 1 not page 0.

