defmodule Arrow.Util do
  @moduledoc false

  @spec sanitized_string_for_sql_like(String.t()) :: String.t()
  def sanitized_string_for_sql_like(string) do
    # See https://github.blog/engineering/like-injection/
    Regex.replace(~r/([\%_])/, string, fn _, x -> "\\#{x}" end) <> "%"
  end
end
