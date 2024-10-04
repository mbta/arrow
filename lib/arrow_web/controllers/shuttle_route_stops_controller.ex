defmodule ArrowWeb.ShuttleRouteStopsController do
  use ArrowWeb, :controller

  alias Arrow.Shuttles
  alias Arrow.Shuttles.ShuttleRouteStops

  def index(conn, _params) do
    shuttle_route_stops = Shuttles.list_shuttle_route_stops()
    render(conn, :index, shuttle_route_stops_collection: shuttle_route_stops)
  end

  def new(conn, _params) do
    changeset = Shuttles.change_shuttle_route_stops(%ShuttleRouteStops{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"shuttle_route_stops" => shuttle_route_stops_params}) do
    case Shuttles.create_shuttle_route_stops(shuttle_route_stops_params) do
      {:ok, shuttle_route_stops} ->
        conn
        |> put_flash(:info, "Shuttle route stops created successfully.")
        |> redirect(to: ~p"/shuttle_route_stops/#{shuttle_route_stops}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shuttle_route_stops = Shuttles.get_shuttle_route_stops!(id)
    render(conn, :show, shuttle_route_stops: shuttle_route_stops)
  end

  def edit(conn, %{"id" => id}) do
    shuttle_route_stops = Shuttles.get_shuttle_route_stops!(id)
    changeset = Shuttles.change_shuttle_route_stops(shuttle_route_stops)
    render(conn, :edit, shuttle_route_stops: shuttle_route_stops, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shuttle_route_stops" => shuttle_route_stops_params}) do
    shuttle_route_stops = Shuttles.get_shuttle_route_stops!(id)

    case Shuttles.update_shuttle_route_stops(shuttle_route_stops, shuttle_route_stops_params) do
      {:ok, shuttle_route_stops} ->
        conn
        |> put_flash(:info, "Shuttle route stops updated successfully.")
        |> redirect(to: ~p"/shuttle_route_stops/#{shuttle_route_stops}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shuttle_route_stops: shuttle_route_stops, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shuttle_route_stops = Shuttles.get_shuttle_route_stops!(id)
    {:ok, _shuttle_route_stops} = Shuttles.delete_shuttle_route_stops(shuttle_route_stops)

    conn
    |> put_flash(:info, "Shuttle route stops deleted successfully.")
    |> redirect(to: ~p"/shuttle_route_stops")
  end
end
