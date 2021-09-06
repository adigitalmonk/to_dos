defmodule ToDosTest do
  use ExUnit.Case
  use ToDos

  doctest ToDos

  to_do("Add tests!")
end
