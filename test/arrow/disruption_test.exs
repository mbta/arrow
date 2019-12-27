defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase, async: true
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Repo

  @start_date ~D[2019-10-10]
  @end_date ~D[2019-12-12]

  describe "database" do
    test "defaults to no disruptions" do
      assert [] = Repo.all(Disruption)
    end

    test "can insert a disruption with no adjustments" do
      assert {:ok, new_dis} =
               Repo.insert(%Disruption{start_date: @start_date, end_date: @end_date},
                 preload: [:adjustments, :exceptions, :trip_short_names]
               )

      new_dis = Repo.preload(new_dis, [:adjustments, :exceptions, :trip_short_names])
      assert new_dis.adjustments == []
      assert new_dis.exceptions == []
      assert new_dis.trip_short_names == []
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
                   start_date: @start_date,
                   end_date: @end_date,
                   adjustments: [new_adj]
                 })
               )

      assert [_] = new_dis.adjustments
    end

    test "can insert a disruption with exceptions" do
      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(%Disruption{}, %{
                   start_date: @start_date,
                   end_date: @end_date,
                   exceptions: [~D[2019-12-01]]
                 })
               )

      assert [_] = new_dis.exceptions
    end

    test "can insert a disruption with short names" do
      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(%Disruption{}, %{
                   start_date: @start_date,
                   end_date: @end_date,
                   trip_short_names: ["006"]
                 })
               )

      assert [_] = new_dis.trip_short_names
    end
  end
end
