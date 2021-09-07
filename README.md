# ToDos

A simple helper for adding TODOs to your code base while also trying to keep you honest about removing them.

Adding a `to_do` to your code base will generate output during build time and leave nothing in the compiled output.
You can also specify a `:deadline` for your `to_do` to force the build to fail if you haven't taken care of your tasks.

## Installation

This module can be installed from the GitHub.

```elixir
  def deps do
    [
      {:to_dos, github: "adigitalmonk/to_dos", tag: "v0.1.0"}
    ]
  end
```

See the [Mix documentation](https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-git-options-git) for more information.

## Usage

The `ToDos` helper provides two macros, the `to_do/2` macro and a simple `__using__` macro.

The `__using__` macro only adds two lines to your module, giving easy access to the `to_do` macro.

```elixir
  require ToDos
  import ToDos
```

The `to_do/2` macro will show your TODO statement at compile time only, leaving nothing behind in your compiled code.

The first argument is the TODO message, and the second is the configurable options.

| Option | Type | Purpose | Default |
| :----: | :---: | :-----: | :-----: |
| `:deadline` |  String/ISO8601 | A drop-dead date for this TODO, will `raise` if the deadline is in the past. | `nil` |


## Examples

### Simple TODO

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
TODO: Implement actual check | MyAppWeb.Plugs.AuthCheck [/project/path/lib/my_app_web/plugs/auth_check.ex#L5]
```

### Time-sensitive TODO

```elixir
defmodule MyApp.Banks.Funcs do
  use ToDos

  def process_some_numbers(bank_accounts) do
    to_do("Make this work with four digit years", deadline: "2000-01-01T00:00:00Z")
    
    Enum.each(bank_accounts, fn bank_account ->
      number_crunch(bank_account)
    end)
  end
end
```

When compiling, you'll see something similar to this:

```shell
== Compilation error in file lib/my_app/banks/funcs.ex ==
** (CompileError) TODO(MyApp.Banks.Funcs): Make this work with four digit years | /project/path/lib/my_app/banks/funcs.ex#L19 | Deadline Exceeded: >= ~U[2000-01-01T00:00:00Z]
    (to_dos 0.1.0) lib/to_dos.ex:41: ToDos.show_to_do/3
    (to_dos 0.1.0) expanding macro: ToDos.to_do/2
    lib/my_app/banks/funcs.ex:5: MyApp.Banks.Funcs.process_some_numbers/1
```
