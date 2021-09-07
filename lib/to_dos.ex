defmodule ToDos do
  defp merge_opts(opts) do
    default_args = [
      deadline: nil
    ]

    Keyword.merge(default_args, opts)
  end

  defp prepare_todo(payload) do
    payload
    |> Enum.reverse()
    |> Enum.join(" | ")
  end

  def show_to_do(message, caller, opts) do
    opts = merge_opts(opts)

    output =
      case message do
        message when is_binary(message) -> ["TODO(#{caller.module}): #{message}"]
        message -> ["TODO(#{caller.module}): #{inspect(message)}"]
      end

    output = ["#{caller.file}\#L#{caller.line}" | output]

    case opts[:deadline] do
      nil ->
        output
        |> prepare_todo()
        |> IO.puts()

      deadline when is_binary(deadline) ->
        no_later_than =
          case DateTime.from_iso8601(deadline) do
            {:ok, no_later_than, _} ->
              no_later_than

            {:error, error} ->
              compile_error("invalid deadline format, #{inspect(error)}")
          end

        if DateTime.compare(DateTime.utc_now(), no_later_than) == :gt do
          error_desc = prepare_todo(["Deadline Exceeded: >= #{inspect(no_later_than)}" | output])
          compile_error(error_desc)
        else
          ["Should be Resolved Before: #{deadline}" | output]
          |> prepare_todo()
          |> IO.puts()
        end

      _ ->
        compile_error("Deadline must be either DateTime or nil")
    end

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
