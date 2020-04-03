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

    test "cannot insert a disruption with no adjustments" do
      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset(
                   %Disruption{},
                   %{
                     start_date: @start_date,
                     end_date: @end_date
                   },
                   []
                 )
               )

      assert Keyword.get(errors, :adjustments)
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
                 Disruption.changeset(
                   %Disruption{},
                   %{
                     start_date: @start_date,
                     end_date: @end_date
                   },
                   [new_adj]
                 )
               )

      assert [_] = new_dis.adjustments
    end

    test "can insert a disruption with exceptions" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "exceptions" => [%{"excluded_date" => ~D[2019-12-01]}]
                   },
                   [new_adj]
                 )
               )

      assert [_] = new_dis.exceptions
    end

    test "can insert a disruption with short names" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "trip_short_names" => [%{"trip_short_name" => "006"}]
                   },
                   [new_adj]
                 )
               )

      assert [_] = new_dis.trip_short_names
    end

    test "can insert a disruption with days of the week (recurrence)" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "days_of_week" => [
                       %{"day_name" => "friday", "start_time" => ~T[20:30:00]},
                       %{"day_name" => "saturday"}
                     ]
                   },
                   [new_adj]
                 )
               )

      assert [friday, saturday] = new_dis.days_of_week

      assert new_dis.adjustments == [new_adj]

      assert friday.day_name == "friday"
      assert friday.start_time == ~T[20:30:00]
      assert friday.end_time == nil

      assert saturday.day_name == "saturday"
      assert saturday.start_time == nil
      assert saturday.end_time == nil
    end
  end
end
