defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Arrow.Stops
  alias Plug.Conn

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, params) do
    stops = Stops.list_stops(params)
    render(conn, :index, stops: stops, order_by: Map.get(params, "order_by"))
  end

  @spec create(Conn.t(), Conn.params()) :: Conn.t()
  def create(conn, %{"stop" => stop_params}) do
    case Stops.create_stop(stop_params) do
      {:ok, _stop} ->
        conn
        |> put_flash(:info, "Stop created successfully.")
        |> redirect(to: ~p"/stops")

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:error, "Unable to create stop, please try again")
        |> redirect(to: ~p"/stops/new")
    end
  end
end
