defmodule ArrowWeb.ShuttleController do
  use ArrowWeb, :controller

  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle

  def index(conn, _params) do
    shuttles = Shuttles.list_shuttles()
    render(conn, :index, shuttles: shuttles)
  end

  def new(conn, _params) do
    changeset =
      Shuttles.change_shuttle(%Shuttle{
        status: :draft,
        routes: [%Shuttles.Route{direction_id: :"0"}, %Shuttles.Route{direction_id: :"1"}]
      })

    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()

    render(conn, :new,
      changeset: changeset,
      gtfs_disruptable_routes: gtfs_disruptable_routes,
      shapes: shapes
    )
  end

  def create(conn, %{"shuttle" => shuttle_params}) do
    case Shuttles.create_shuttle(shuttle_params) do
      {:ok, shuttle} ->
        conn
        |> put_flash(:info, "Shuttle created successfully.")
        |> redirect(to: ~p"/shuttles/#{shuttle}")

      {:error, %Ecto.Changeset{} = changeset} ->
        gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
        shapes = Shuttles.list_shapes()

        render(conn, :new,
          changeset: changeset,
          gtfs_disruptable_routes: gtfs_disruptable_routes,
          shapes: shapes
        )
    end
  end

  def show(conn, %{"id" => id}) do
    shuttle = Shuttles.get_shuttle!(id)
    render(conn, :show, shuttle: shuttle)
  end

  def edit(conn, %{"id" => id}) do
    shuttle = Shuttles.get_shuttle!(id)
    changeset = Shuttles.change_shuttle(shuttle)
    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()

    render(conn, :edit,
      shuttle: shuttle,
      changeset: changeset,
      gtfs_disruptable_routes: gtfs_disruptable_routes,
      shapes: shapes
    )
  end

  def update(conn, %{"id" => id, "shuttle" => shuttle_params}) do
    shuttle = Shuttles.get_shuttle!(id)

    case Shuttles.update_shuttle(shuttle, shuttle_params) do
      {:ok, shuttle} ->
        conn
        |> put_flash(:info, "Shuttle updated successfully.")
        |> redirect(to: ~p"/shuttles/#{shuttle}")

      {:error, %Ecto.Changeset{} = changeset} ->
        gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
        shapes = Shuttles.list_shapes()

        render(conn, :edit,
          shuttle: shuttle,
          changeset: changeset,
          gtfs_disruptable_routes: gtfs_disruptable_routes,
          shapes: shapes
        )
    end
  end
end
