defmodule ArrowWeb.ErrorHelpersTest do
  use ExUnit.Case, async: true

  alias ArrowWeb.ErrorHelpers

  describe "flatten_errors/1" do
    test "flattens a nested error map into a list of strings" do
      errors = %{
        some_field: ["is invalid", %{nested_field: ["is also invalid"]}],
        other_field: ["has a problem", "has two problems"]
      }

      expected = [
        "Other field has a problem",
        "Other field has two problems",
        "Some field is invalid",
        "Some field: nested field is also invalid"
      ]

      assert ErrorHelpers.flatten_errors(errors) == expected
    end
  end
end
