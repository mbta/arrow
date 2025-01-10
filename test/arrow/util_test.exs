defmodule Arrow.UtilTest do
  use ExUnit.Case, async: true

  alias Arrow.Util

  describe "sanitized_string_for_sql_like/1" do
    test "Escapes % characters" do
      assert Util.sanitized_string_for_sql_like("%foo") == "\\%foo%"
    end

    test "Escapes _ characters" do
      assert Util.sanitized_string_for_sql_like("_foo") == "\\_foo%"
    end

    test "Makes no changes to other random characters" do
      assert Util.sanitized_string_for_sql_like("f$o*o!") == "f$o*o!%"
    end
  end
end
