defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Repo

  @start_date ~D[2019-10-10]
  @end_date ~D[2019-12-12]
  @current_time DateTime.from_naive!(~N[2019-04-15 12:00:00], "America/New_York")

  describe "database" do
    test "defaults to no disruptions" do
      assert [] = Repo.all(Disruption)
    end

    test "cannot insert a disruption with no adjustments" do
      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     start_date: @start_date,
                     end_date: @end_date
                   },
                   [],
                   @current_time
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
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     start_date: @start_date,
                     end_date: @end_date
                   },
                   [new_adj],
                   @current_time
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
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "exceptions" => [%{"id" => 1234, "excluded_date" => ~D[2019-12-01]}]
                   },
                   [new_adj],
                   @current_time
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
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "trip_short_names" => [%{"trip_short_name" => "006"}]
                   },
                   [new_adj],
                   @current_time
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
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "days_of_week" => [
                       %{"day_name" => "friday", "start_time" => ~T[20:30:00]},
                       %{"day_name" => "saturday"}
                     ]
                   },
                   [new_adj],
                   @current_time
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

    test "can update a disruption" do
      new_start_date = ~D[2019-10-15]
      new_end_date = ~D[2019-12-17]

      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      {:ok, new_dis} =
        Repo.insert(
          Disruption.changeset_for_create(
            %Disruption{},
            %{
              start_date: @start_date,
              end_date: @end_date
            },
            [new_adj],
            @current_time
          )
        )

      assert {:ok, updated_dis} =
               Repo.update(
                 Disruption.changeset_for_update(
                   new_dis,
                   %{
                     start_date: new_start_date,
                     end_date: new_end_date
                   },
                   @current_time
                 )
               )

      assert updated_dis.start_date == new_start_date
      assert updated_dis.end_date == new_end_date
    end

    test "can update days of week on a disruption" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      {:ok, new_dis} =
        Repo.insert(
          Disruption.changeset_for_create(
            %Disruption{},
            %{
              "start_date" => @start_date,
              "end_date" => @end_date,
              "days_of_week" => [
                %{"day_name" => "friday"},
                %{"day_name" => "saturday"}
              ]
            },
            [new_adj],
            @current_time
          )
        )

      saturday_dow = Enum.find(new_dis.days_of_week, &(&1.day_name == "saturday"))

      assert {:ok, updated_dis} =
               Repo.update(
                 Disruption.changeset_for_update(
                   new_dis,
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "days_of_week" => [
                       %{"id" => saturday_dow.id, "day_name" => saturday_dow.day_name},
                       %{"day_name" => "sunday"}
                     ]
                   },
                   @current_time
                 )
               )

      day_names = Enum.map(updated_dis.days_of_week, & &1.day_name)

      assert Enum.count(day_names) == 2
      assert "saturday" in day_names
      assert "sunday" in day_names
    end

    test "can update exceptions on a disruption" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      {:ok, new_dis} =
        Repo.insert(
          Disruption.changeset_for_create(
            %Disruption{},
            %{
              "start_date" => @start_date,
              "end_date" => @end_date,
              "exceptions" => [
                %{"excluded_date" => ~D[2019-11-01]},
                %{"excluded_date" => ~D[2019-11-02]}
              ]
            },
            [new_adj],
            @current_time
          )
        )

      exception_to_keep = Enum.find(new_dis.exceptions, &(&1.excluded_date == ~D[2019-11-02]))

      assert {:ok, updated_dis} =
               Repo.update(
                 Disruption.changeset_for_update(
                   new_dis,
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "exceptions" => [
                       %{
                         "id" => exception_to_keep.id,
                         "excluded_date" => exception_to_keep.excluded_date
                       },
                       %{"excluded_date" => ~D[2019-11-03]}
                     ]
                   },
                   @current_time
                 )
               )

      excluded_dates = Enum.map(updated_dis.exceptions, & &1.excluded_date)

      assert Enum.count(excluded_dates) == 2
      assert ~D[2019-11-02] in excluded_dates
      assert ~D[2019-11-03] in excluded_dates
    end

    test "can update trip short names on a disruption" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      {:ok, new_dis} =
        Repo.insert(
          Disruption.changeset_for_create(
            %Disruption{},
            %{
              "start_date" => @start_date,
              "end_date" => @end_date,
              "trip_short_names" => [
                %{"trip_short_name" => "123"},
                %{"trip_short_name" => "456"}
              ]
            },
            [new_adj],
            @current_time
          )
        )

      short_name_to_keep = Enum.find(new_dis.trip_short_names, &(&1.trip_short_name == "456"))

      assert {:ok, updated_dis} =
               Repo.update(
                 Disruption.changeset_for_update(
                   new_dis,
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "trip_short_names" => [
                       %{
                         "id" => short_name_to_keep.id,
                         "trip_short_name" => short_name_to_keep.trip_short_name
                       },
                       %{"trip_short_name" => "789"}
                     ]
                   },
                   @current_time
                 )
               )

      short_names = Enum.map(updated_dis.trip_short_names, & &1.trip_short_name)

      assert Enum.count(short_names) == 2
      assert "456" in short_names
      assert "789" in short_names
    end

    test "Can't delete exception date that's in the past" do
      disruption = build_disruption()

      disruption =
        put_in(disruption.exceptions, [%Arrow.Disruption.Exception{excluded_date: ~D[2000-01-01]}])

      changeset =
        Disruption.changeset_for_update(
          disruption,
          %{"exceptions" => []},
          @current_time
        )

      refute changeset.valid?
      assert %{exceptions: ["can't be deleted from the past."]} = errors_on(changeset)
    end
  end
end
