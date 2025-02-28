defmodule Arrow.Shuttles.ShuttleTest do
  use Arrow.DataCase

  alias Arrow.Shuttles.Shuttle

  import Arrow.Factory
  import Arrow.ShuttlesFixtures

  describe "changeset/2" do
    test "cannot mark a shuttle as active without at least two shuttle_stops per shuttle_route" do
      shuttle = shuttle_fixture()

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [status: {"must have at least two stops in each direction", []}]
             } = changeset
    end

    test "cannot mark a shuttle as active without times to next stop on applicable stops" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 status:
                   {"all stops except the last in each direction must have a time to next stop",
                    []}
               ]
             } = changeset
    end

    test "can mark a shuttle as active with at least two shuttle_stops per shuttle_route and time_to_next_stop values" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      shuttle = Arrow.Shuttles.get_shuttle!(shuttle.id)

      changeset = Shuttle.changeset(shuttle, %{status: :active})

      assert %Ecto.Changeset{valid?: true} = changeset
    end

    test "cannot mark a shuttle as inactive when in use by a replacement service" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      {:ok, shuttle} =
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()
        |> Shuttle.changeset(%{status: :active})
        |> Arrow.Repo.update()

      insert(:replacement_service, shuttle: shuttle)

      changeset = Shuttle.changeset(shuttle, %{status: :draft})

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 status:
                   {"cannot set to a non-active status while in use as a replacement service", []}
               ]
             } = changeset
    end

    test "can mark a shuttle as inactive when not in use by a replacement service" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop2.id
          }
        ]
      })
      |> Arrow.Repo.update()

      route1
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "1",
            "stop_sequence" => "1",
            "display_stop_id" => stop3.id,
            "time_to_next_stop" => 30.0
          },
          %{
            "direction_id" => "0",
            "stop_sequence" => "2",
            "display_stop_id" => stop4.id
          }
        ]
      })
      |> Arrow.Repo.update()

      {:ok, shuttle} =
        shuttle.id
        |> Arrow.Shuttles.get_shuttle!()
        |> Shuttle.changeset(%{status: :active})
        |> Arrow.Repo.update()

      changeset = Shuttle.changeset(shuttle, %{status: :draft})

      assert %Ecto.Changeset{valid?: true} = changeset
    end
  end
end
