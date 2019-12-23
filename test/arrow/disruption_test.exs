defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase, async: true
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Repo

  describe "database" do
    test "defaults to no disruptions" do
      assert [] = Repo.all(Disruption)
    end

    test "can insert a disruption with no adjustments" do
      assert {:ok, _} =
               Repo.insert(%Disruption{start_date: ~D[2019-10-10], end_date: ~D[2019-12-12]})
    end

    test "can insert a disruption with adjustments" do
      adj = %Adjustment{
        source: "testing",
        source_label: "NewtonHighlandsKenmore",
        route_id: "Green-D"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(%Disruption{}, %{
                   start_date: ~D[2019-10-10],
                   end_date: ~D[2019-12-12],
                   adjustments: [new_adj]
                 })
               )

      assert [_] = new_dis.adjustments
    end
  end
end
