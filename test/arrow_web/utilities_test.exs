defmodule ArrowWeb.UtilitiesTest do
  use Arrow.DataCase
  import ArrowWeb.Utilities
  alias Arrow.Disruption

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

  describe "format_errors/1" do
    test "parses changeset errors correctly" do
      {:error, cs} =
        Disruption.create(
          %{
            "end_date" => ~D[2019-12-12],
            "days_of_week" => [
              %{
                "day_name" => "friday",
                "start_time" => ~T[20:30:00],
                "end_time" => ~T[19:30:00]
              },
              %{"day_name" => "saturday"}
            ]
          },
          []
        )

      formatted = format_errors(cs)

      assert Enum.find(formatted, &(&1.detail == "Adjustments should have at least 1 item(s)"))

      assert Enum.find(
               formatted,
               &(&1.detail == "Days of week start time should be before end time")
             )

      assert Enum.find(formatted, &(&1.detail == "Start date can't be blank"))
    end
  end
end
