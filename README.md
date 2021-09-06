# ToDos

A simple helper for adding TODOs to your code base while also trying to keep you honest about removing them.

Adding a `to_do` to your code base will generate output during build time and leave nothing in the compiled output.
You can also specify a `:deadline` for your `to_do` to force the build to fail if you haven't taken care of your tasks.

## Installation

TBD.

## Usage

The `ToDos` helper provides two macros, the `to_do/2` macro and a simple `__using__` macro.

The `__using__` macro only adds two lines to your module, giving access to the `to_do` macro.

```elixir
  require ToDos
  import ToDos
```

The macro itself is simple enough and will output at compile time only.

```elixir
defmodule MyAppWeb.Plugs.AuthCheck do
  use ToDos

  def auth_check(conn, _opt) do
    to_do("Implement actual check")
    conn
  end
end
```

When compiling, you'll see something similar to this:

```shell
> mix compile
==> my_app_web
Compiling 1 file (.ex)
TODO: "Implement actual check" | In [file: "/project/path/lib/my_app_web/plugs/auth_check.ex", module: MyAppWeb.Plugs.AuthCheck]
```

The second argument for `to_do/2` are the configurable options.

| Option | Type | Purpose | Default |
| :----: | :---: | :-----: | :-----: |
| `:caller` | Boolean | Whether to show the caller file and module | `true` |
| `:deadline` |  String/ISO8601 | A drop-dead date for this TODO, will `raise` if the deadline is in the past. | `nil` |

