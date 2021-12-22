defmodule ToDos do
  defp add_defaults(opts) do
    Keyword.put_new(opts, :deadline, nil)
  end

  defp prepare_todo(payload) do
    payload
    |> Enum.reverse()
    |> Enum.join(" | ")
  end

  defp add_deadline(output, nil), do: output

  defp add_deadline(output, deadline) when is_binary(deadline) do
    no_later_than =
      case DateTime.from_iso8601(deadline) do
        {:ok, no_later_than, _} -> no_later_than
        {:error, error} -> compile_error("invalid deadline format, #{inspect(error)}")
      end

    if DateTime.compare(DateTime.utc_now(), no_later_than) == :gt do
      ["Deadline Exceeded: >= #{inspect(no_later_than)}" | output]
      |> prepare_todo()
      |> compile_error()
    else
      ["Should be Resolved Before: #{deadline}" | output]
    end
  end

  defp add_deadline(_, _), do: compile_error("Deadline must be either ISO 8601 string or nil")

  def show_to_do(message, caller, opts) do
    opts = add_defaults(opts)

    message
    |> case do
      message when is_binary(message) -> ["TODO(#{caller.module}): #{message}"]
      message -> ["TODO(#{caller.module}): #{inspect(message)}"]
    end
    |> then(&["#{caller.file}\#L#{caller.line}" | &1])
    |> add_deadline(opts[:deadline])
    |> prepare_todo()
    |> IO.puts()

    :ok
  end

  defp compile_error(description) do
    raise %CompileError{description: description}
  end

  defmacro to_do(message, opts \\ []) do
    show_to_do(message, __CALLER__, opts)
    nil
  end

  defmacro __using__(_opts) do
    quote do
      require ToDos
      import ToDos
    end
  end
end
