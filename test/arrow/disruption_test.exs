defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase
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
        source_label: "test_insert_disruption",
        route_id: "test_route"
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

    test "can insert a disruption with days of the week (recurrence)" do
      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(%Disruption{}, %{
                   start_date: @start_date,
                   end_date: @end_date,
                   days_of_week: [
                     %{day_name: "friday", start_time: ~T[20:30:00]},
                     %{day_name: "saturday"}
                   ]
                 })
               )

      assert [friday, saturday] = new_dis.days_of_week

      assert friday.day_name == "friday"
      assert friday.start_time == ~T[20:30:00]
      assert friday.end_time == nil

      assert saturday.day_name == "saturday"
      assert saturday.start_time == nil
      assert saturday.end_time == nil
    end
  end
end
