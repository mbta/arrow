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

    test "can mark a shuttle as active with at least two shuttle_stops per shuttle_route" do
      shuttle = shuttle_fixture()
      [route0, route1] = shuttle.routes

      [stop1, stop2, stop3, stop4] = insert_list(4, :gtfs_stop)

      route0
      |> Arrow.Shuttles.Route.changeset(%{
        "route_stops" => [
          %{
            "direction_id" => "0",
            "stop_sequence" => "1",
            "display_stop_id" => stop1.id
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

      assert %Ecto.Changeset{valid?: true} = changeset
    end
  end
end
