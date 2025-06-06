defmodule Arrow.AdjustmentTest do
  @moduledoc false
  use Arrow.DataCase

  alias Arrow.Adjustment
  alias Arrow.Repo

  describe "database" do
    test "can insert an adjustment" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_adjustment",
        route_id: "test_route"
      }

      assert {:ok, new_adj} = Repo.insert(adj)
      assert adj.source == new_adj.source
      assert adj.source_label == new_adj.source_label
      assert adj.route_id == new_adj.route_id

      assert new_adj in Repo.all(Adjustment)
    end

    test "source_label is unique" do
      adj1 = %Adjustment{
        source: "testing1",
        source_label: "test_unique_source_label",
        route_id: "test_route"
      }

      adj2 = %Adjustment{
        source: "testing2",
        source_label: "test_unique_source_label",
        route_id: "test_route"
      }

      assert {:ok, _} = Repo.insert(adj1)
      assert {:error, _} = Repo.insert(Adjustment.changeset(adj2, %{}))
    end
  end

  describe "display_label/1" do
    defp display_label(label), do: Adjustment.display_label(%Adjustment{source_label: label})

    test "returns a friendlier label for the adjustment" do
      assert display_label("AirportBowdoinExpress") == "Airport Bowdoin Express"
      assert display_label("GreenEStopAtBrighamCircle") == "Green E Stop At Brigham Circle"
      assert display_label("AshmontJFK") == "Ashmont JFK"
      assert display_label("SL2NoTransitwayAM") == "SL2 No Transitway AM"
    end
  end
end
