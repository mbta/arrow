defmodule ArrowWeb.ShuttleRouteController do
  use ArrowWeb, :controller

  alias Arrow.Shuttles
  alias Arrow.Shuttles.ShuttleRoute

  def index(conn, _params) do
    shuttle_routes = Shuttles.list_shuttle_routes()
    render(conn, :index, shuttle_routes: shuttle_routes)
  end

  def new(conn, _params) do
    changeset = Shuttles.change_shuttle_route(%ShuttleRoute{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"shuttle_route" => shuttle_route_params}) do
    case Shuttles.create_shuttle_route(shuttle_route_params) do
      {:ok, shuttle_route} ->
        conn
        |> put_flash(:info, "Shuttle route created successfully.")
        |> redirect(to: ~p"/shuttle_routes/#{shuttle_route}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shuttle_route = Shuttles.get_shuttle_route!(id)
    render(conn, :show, shuttle_route: shuttle_route)
  end

  def edit(conn, %{"id" => id}) do
    shuttle_route = Shuttles.get_shuttle_route!(id)
    changeset = Shuttles.change_shuttle_route(shuttle_route)
    render(conn, :edit, shuttle_route: shuttle_route, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shuttle_route" => shuttle_route_params}) do
    shuttle_route = Shuttles.get_shuttle_route!(id)

    case Shuttles.update_shuttle_route(shuttle_route, shuttle_route_params) do
      {:ok, shuttle_route} ->
        conn
        |> put_flash(:info, "Shuttle route updated successfully.")
        |> redirect(to: ~p"/shuttle_routes/#{shuttle_route}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shuttle_route: shuttle_route, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shuttle_route = Shuttles.get_shuttle_route!(id)
    {:ok, _shuttle_route} = Shuttles.delete_shuttle_route(shuttle_route)

    conn
    |> put_flash(:info, "Shuttle route deleted successfully.")
    |> redirect(to: ~p"/shuttle_routes")
  end
end
