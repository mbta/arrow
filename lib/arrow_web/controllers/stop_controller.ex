defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Arrow.Shuttle.Stop
  alias Arrow.Stops
  alias Plug.Conn

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, params) do
    stops = Stops.list_stops(params)
    render(conn, :index, stops: stops, order_by: Map.get(params, "order_by"))
  end

  @spec new(Conn.t(), Conn.params()) :: Conn.t()
  def new(conn, _params) do
    changeset = Stops.change_stop(%Stop{})
    render(conn, :new, changeset: changeset)
  end

  @spec create(Conn.t(), Conn.params()) :: Conn.t()
  def create(conn, %{"stop" => stop_params}) do
    case Stops.create_stop(stop_params) do
      {:ok, _stop} ->
        conn
        |> put_flash(:info, "Stop created successfully.")
        |> redirect(to: ~p"/stops")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  @spec edit(Conn.t(), Conn.params()) :: Conn.t()
  def edit(conn, %{"id" => id}) do
    stop = Stops.get_stop!(id)
    changeset = Stops.change_stop(stop)
    render(conn, :edit, stop: stop, changeset: changeset)
  end

  @spec update(Conn.t(), Conn.params()) :: Conn.t()
  def update(conn, %{"id" => id, "stop" => stop_params}) do
    stop = Stops.get_stop!(id)

    case Stops.update_stop(stop, stop_params) do
      {:ok, _stop} ->
        conn
        |> put_flash(:info, "Stop updated successfully.")
        |> redirect(to: ~p"/stops")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, stop: stop, changeset: changeset)
    end
  end
end
