---
layout: til_post
title:  "Exclude tags when running ExUnit tests"
categories: til
disq_id: til-28
redirect_from: 
  - "/tils/28"
  - "/tils/28-exclude-tags-when-running-exunit-tests"
---

Let say you have tests that trigger real HTTP calls (e.g.: contracts).
And you want those to be excluded from the default test run.

```elixir
# test/lib/twitter_test.exs
defmodule MyApp.Twitter.HTTPTest do
  use ExUnit.case, async: true

  @moduletag :twitter_api

  # ...
end

# test/test_helper.exs
> ...
ExUnit.configure exclude: [:twitter_api]  # exclude this tagged test from default test run

```

In order to run thest with the `twitter_api` tag:

```bash
mix test --include twitter_api
```

To run just these tagged tests:

```bash
mix test --only twitter_api
```


Source:

* <http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/>
