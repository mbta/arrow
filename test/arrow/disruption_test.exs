defmodule Arrow.DisruptionTest do
  @moduledoc false
  use Arrow.DataCase
  alias Arrow.Adjustment
  alias Arrow.Disruption
  alias Arrow.Disruption.DayOfWeek
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

    test "cannot insert a disruption with a start_date later than end_date" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     start_date: ~D[2020-02-01],
                     end_date: ~D[2020-01-20]
                   },
                   [new_adj],
                   @current_time
                 )
               )

      assert Keyword.get(errors, :start_date) == {"can't be after end date.", []}
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
                     "exceptions" => [%{"id" => 1234, "excluded_date" => @start_date}],
                     "days_of_week" => [
                       %{"day_name" => DayOfWeek.date_to_day_name(@start_date)}
                     ]
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

      assert {:ok, new_dis} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => ~D[2020-01-02],
                     "end_date" => ~D[2020-01-05],
                     "days_of_week" => [
                       %{"day_name" => "friday", "start_time" => ~T[20:30:00]},
                       %{"day_name" => "saturday"}
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )
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
              "days_of_week" => [%{"day_name" => DayOfWeek.date_to_day_name(~D[2019-11-01])}],
              "exceptions" => [
                %{"excluded_date" => ~D[2019-11-01]},
                %{"excluded_date" => ~D[2019-11-08]}
              ]
            },
            [new_adj],
            @current_time
          )
        )

      exception_to_keep = Enum.find(new_dis.exceptions, &(&1.excluded_date == ~D[2019-11-01]))

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
                       %{"excluded_date" => ~D[2019-11-15]}
                     ]
                   },
                   @current_time
                 )
               )

      excluded_dates = Enum.map(updated_dis.exceptions, & &1.excluded_date)

      assert Enum.count(excluded_dates) == 2
      assert ~D[2019-11-01] in excluded_dates
      assert ~D[2019-11-15] in excluded_dates
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
      start_date = ~D[2020-01-01]
      end_date = ~D[2020-01-20]
      disruption = build_disruption(%Arrow.Disruption{start_date: start_date, end_date: end_date})

      disruption =
        put_in(disruption.exceptions, [%Arrow.Disruption.Exception{excluded_date: ~D[2020-01-02]}])

      changeset =
        Disruption.changeset_for_update(
          disruption,
          %{"exceptions" => []},
          DateTime.from_naive!(~N[2020-01-15 12:00:00], "America/New_York")
        )

      refute changeset.valid?
      assert %{exceptions: ["can't be deleted from the past."]} = errors_on(changeset)
    end

    test "Can't change days of week for disruption in past" do
      disruption = build_disruption()

      disruption =
        put_in(disruption.days_of_week, [%Arrow.Disruption.DayOfWeek{day_name: "tuesday"}])

      disruption = put_in(disruption.start_date, ~D[2020-04-01])

      now = DateTime.from_naive!(~N[2020-04-15 12:00:00], "America/New_York")

      changeset =
        Disruption.changeset_for_update(
          disruption,
          %{"days_of_week" => [%{"day_name" => "monday"}]},
          now
        )

      refute changeset.valid?

      assert %{days_of_week: ["can't be changed because start date is in the past."]} =
               errors_on(changeset)
    end

    test "Can't change trip short names for disruption in past" do
      disruption = build_disruption()

      disruption =
        put_in(disruption.trip_short_names, [
          %Arrow.Disruption.TripShortName{trip_short_name: "short"}
        ])

      disruption = put_in(disruption.start_date, ~D[2020-04-01])

      now = DateTime.from_naive!(~N[2020-04-15 12:00:00], "America/New_York")

      changeset =
        Disruption.changeset_for_update(
          disruption,
          %{"trip_short_names" => []},
          now
        )

      refute changeset.valid?

      assert %{trip_short_names: ["can't be changed because start date is in the past."]} =
               errors_on(changeset)
    end

    test "Can't insert a disruption with exceptions falling outside the date range" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => Date.add(@start_date, 5),
                     "days_of_week" => [
                       %{
                         "day_name" => @start_date |> Date.day_of_week() |> DayOfWeek.day_name(),
                         "start_time" => ~T[20:30:00]
                       }
                     ],
                     "exceptions" => [
                       %{
                         "id" => 1234,
                         "excluded_date" => @start_date |> Date.add(7)
                       }
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )

      assert Keyword.get(errors, :exceptions) == {"should fall between start and end dates", []}
    end

    test "Can't insert a disruption with duplicate exceptions" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => Date.add(@start_date, 10),
                     "days_of_week" => [
                       %{
                         "day_name" => @start_date |> Date.day_of_week() |> DayOfWeek.day_name(),
                         "start_time" => ~T[20:30:00]
                       }
                     ],
                     "exceptions" => [
                       %{"id" => 1234, "excluded_date" => @start_date},
                       %{"id" => 1235, "excluded_date" => @start_date}
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )

      assert Keyword.get(errors, :exceptions) == {"should be unique", []}
    end

    test "Can't insert a disruption with exceptions not applicable to days_of_week" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => Date.add(@start_date, 3),
                     "days_of_week" => [
                       %{
                         "day_name" => @start_date |> Date.day_of_week() |> DayOfWeek.day_name(),
                         "start_time" => ~T[20:30:00]
                       }
                     ],
                     "exceptions" => [
                       %{
                         "id" => 1234,
                         "excluded_date" => @start_date |> Date.add(2)
                       }
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )

      assert Keyword.get(errors, :exceptions) == {"should be applicable to days of week", []}
    end

    test "Can't insert a disruption with a day_of_week having a start_time later than end_time" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error,
              %{
                changes: %{
                  days_of_week: [
                    %{
                      changes: %{
                        day_name: "friday",
                        end_time: ~T[19:30:00],
                        start_time: ~T[20:30:00]
                      },
                      errors: [days_of_week: {"start time should be before end time", []}],
                      valid?: false
                    },
                    %{
                      changes: %{day_name: "saturday"},
                      errors: [],
                      valid?: true
                    }
                  ]
                },
                errors: []
              }} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "days_of_week" => [
                       %{
                         "day_name" => "friday",
                         "start_time" => ~T[20:30:00],
                         "end_time" => ~T[19:30:00]
                       },
                       %{"day_name" => "saturday"}
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )
    end

    test "Can't insert a disruption with a day_of_week falling outside date range" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error, %{errors: errors}} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => Date.add(@start_date, 3),
                     "days_of_week" => [
                       %{"day_name" => @start_date |> Date.add(5) |> DayOfWeek.date_to_day_name()}
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )

      assert Keyword.get(errors, :days_of_week) == {"should fall between start and end dates", []}
    end

    test "can't insert a disruption with a blank trip short name" do
      adj = %Adjustment{
        source: "testing",
        source_label: "test_insert_disruption",
        route_id: "test_route"
      }

      {:ok, new_adj} = Repo.insert(adj)

      assert {:error,
              %{
                changes: %{
                  trip_short_names: [
                    %{
                      changes: %{},
                      errors: [trip_short_name: {"can't be blank", [validation: :required]}],
                      valid?: false
                    }
                  ]
                },
                errors: []
              }} =
               Repo.insert(
                 Disruption.changeset_for_create(
                   %Disruption{},
                   %{
                     "start_date" => @start_date,
                     "end_date" => @end_date,
                     "trip_short_names" => [
                       %{
                         "trip_short_name" => ""
                       }
                     ]
                   },
                   [new_adj],
                   @current_time
                 )
               )
    end

    test "can delete a disruption" do
      {:ok, disruption} = build_disruption() |> Repo.insert()

      assert {:ok, %Disruption{}} =
               disruption
               |> Disruption.changeset_for_delete(@current_time)
               |> Repo.delete()
    end

    test "can't delete a disruption with a start date in the past" do
      {:ok, disruption} =
        build_disruption(%Disruption{
          start_date: @current_time |> DateTime.to_date() |> Date.add(-1)
        })
        |> Repo.insert()

      assert {:error, changeset} =
               disruption
               |> Disruption.changeset_for_delete(@current_time)
               |> Repo.delete()

      assert changeset.errors == [
               start_date: {"can't be deleted when start date is in the past", []}
             ]
    end
  end
end
