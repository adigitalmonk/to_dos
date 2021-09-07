defmodule ToDosTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  import ToDos

  setup do
    %{
      caller: %{
        file: "file_name.ex",
        module: __MODULE__,
        line: 1
      }
    }
  end

  describe "show_to_do/2" do
    test "logs but doesn't return quoted code", %{caller: caller} do
      expected_test_message = "test"

      to_do_output =
        capture_io(fn ->
          assert show_to_do(expected_test_message, caller, []) == :ok
        end)

      assert to_do_output =~ "TODO(#{caller.module}): #{expected_test_message}"
      assert to_do_output =~ "#{caller.file}\#L#{caller.line}"
    end

    test "can output objects", %{caller: caller} do
      expected_test_message = %{test: "thing"}

      to_do_output =
        capture_io(fn ->
          assert show_to_do(expected_test_message, caller, []) == :ok
        end)

      assert to_do_output =~ inspect(expected_test_message)
    end

    test "raises if invalid deadline", %{caller: caller} do
      %CompileError{description: message} =
        assert_raise CompileError, fn -> show_to_do("test", caller, deadline: "test") end

      assert message =~ "invalid deadline format"
    end

    test "notifies if deadline in future", %{caller: caller} do
      in_the_future =
        DateTime.utc_now()
        |> DateTime.add(60, :second)
        |> DateTime.to_iso8601()

      to_do_output =
        capture_io(fn ->
          show_to_do("test", caller, deadline: in_the_future)
        end)

      assert to_do_output =~ "Should be Resolved Before: #{in_the_future}"
    end

    test "raises if past deadline", %{caller: caller} do
      before_now =
        DateTime.utc_now()
        |> DateTime.add(-60, :second)
        |> DateTime.to_iso8601()

      %CompileError{description: message} =
        assert_raise CompileError, fn -> show_to_do("test", caller, deadline: before_now) end

      assert message =~ "Deadline Exceeded"
    end
  end
end
