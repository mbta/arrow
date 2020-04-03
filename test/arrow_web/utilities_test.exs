defmodule ArrowWeb.UtilitiesTest do
  use ExUnit.Case, async: true
  import ArrowWeb.Utilities

  describe "get_json_api_relationships/1" do
    test "parses the data correctly" do
      data = %{
        "rel1" => %{"data" => %{"attributes" => %{"attr1" => "val1"}}},
        "rel2" => %{"data" => [%{"attributes" => %{"attr2" => "val2"}}]}
      }

      assert %{
               "rel1" => %{"attr1" => "val1"},
               "rel2" => [%{"attr2" => "val2"}]
             } = get_json_api_relationships(data)
    end
  end
end
