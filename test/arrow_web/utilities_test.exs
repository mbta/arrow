defmodule ArrowWeb.UtilitiesTest do
  use ExUnit.Case, async: true
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
      cs =
        Disruption.changeset_for_create(
          %Disruption{},
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
          [],
          DateTime.from_naive!(~N[2019-04-15 12:00:00], "America/New_York")
        )

      assert [
               %{detail: "Adjustments should have at least 1 item(s)"},
               %{detail: "Days of week start time should be before end time"},
               %{detail: "Start date can't be blank"}
             ] = format_errors(cs)
    end
  end
end
