defmodule Test.Support.Helpers do
  defmacro reassign_env(var, value) do
    quote do
      old_value = Application.get_env(:arrow, unquote(var))
      Application.put_env(:arrow, unquote(var), unquote(value))

      on_exit(fn ->
        Application.put_env(:arrow, unquote(var), old_value)
      end)
    end
  end
end
