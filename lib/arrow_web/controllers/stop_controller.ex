defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Arrow.Stops
  alias ArrowWeb.ErrorHelpers
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

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(
          :errors,
          {"Error creating stop, please try again",
           ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> redirect(to: ~p"/stops/new")
    end
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
        conn
        |> put_flash(
          :errors,
          {"Error updating stop, please try again",
           ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> redirect(to: ~p"/stops/#{stop}/edit")
    end
  end
end
