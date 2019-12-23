defmodule Arrow.AdjustmentTest do
  @moduledoc false
  use Arrow.DataCase, async: true
  alias Arrow.Adjustment
  alias Arrow.Repo

  describe "database" do
    test "starts with no adjustments" do
      assert [] = Repo.all(Adjustment)
    end

    test "can insert an adjustment" do
      adj = %Adjustment{
        source: "testing",
        source_label: "NewtonHighlandsKenmore",
        route_id: "Green-D"
      }

      assert {:ok, new_adj} = Repo.insert(adj)
      assert adj.source == new_adj.source
      assert adj.source_label == new_adj.source_label
      assert adj.route_id == new_adj.route_id

      assert [^new_adj] = Repo.all(Adjustment)
    end

    test "source/source_label is unique" do
      adj = %Adjustment{
        source: "testing",
        source_label: "NewtonHighlandsKenmore",
        route_id: "Green-D"
      }

      assert {:ok, _} = Repo.insert(adj)
      assert {:error, _} = Repo.insert(Adjustment.changeset(adj, %{}))
    end
  end
end
