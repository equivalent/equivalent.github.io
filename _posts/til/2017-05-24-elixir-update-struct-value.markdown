---
layout: til_post
title:  "Elixir - update struct value"
categories: til
disq_id: til-21
redirect_from:
  - "/tils/21"
  - "/tils/21-elixir-update-struct-value"
---



[https://elixir-lang.org/getting-started/structs.html](https://elixir-lang.org/getting-started/structs.html)

```elixir
user = %User{age: 27, name: "John"}
user = %User{ user | last_name: "Smith"}
```
