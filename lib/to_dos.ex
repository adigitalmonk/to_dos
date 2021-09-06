defmodule ToDos do
  def merge_opts(opts) do
    default_args = [
      caller: true,
      deadline: nil
    ]

    Keyword.merge(default_args, opts)
  end

  def prepare_todo(payload) do
    payload
    |> Enum.reverse()
    |> Enum.join(" | ")
  end

  defmacro to_do(message, opts \\ []) do
    opts = merge_opts(opts)
    output = ["TODO: #{inspect(message)}"]

    output =
      case opts[:caller] do
        true -> ["In #{inspect(file: __CALLER__.file, module: __CALLER__.module)}" | output]
        false -> output
      end

    case opts[:deadline] do
      nil ->
        output
        |> prepare_todo()
        |> IO.puts()

      deadline when is_binary(deadline) ->
        no_later_than =
          case DateTime.from_iso8601(deadline) do
            {:ok, no_later_than, _} -> no_later_than
            {:error, error} -> raise "invalid deadline format, #{inspect(error)}"
          end

        if DateTime.compare(DateTime.utc_now(), no_later_than) == :gt do
          raise prepare_todo(["Deadline Exceeded: >= #{inspect(no_later_than)}" | output])
        else
          prepare_todo(["Should be Resolved Before: #{inspect(no_later_than)}" | output])
          |> IO.puts()
        end

      _ ->
        raise "Deadline must be either DateTime or nil"
    end
  end

  defmacro __using__(_opts) do
    quote do
      require ToDos
      import ToDos
    end
  end
end
