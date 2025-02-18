defmodule ArrowWeb.API.ReplacementServiceController do
  use ArrowWeb, :controller

  alias Arrow.Disruptions.ReplacementService
  alias ArrowWeb.API.Util
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, params) do
    with {:ok, start_date} <- Util.parse_date(params["start_date"]),
         {:ok, end_date} <- Util.parse_date(params["end_date"]),
         :ok <- Util.validate_date_order(start_date, end_date) do
      data = ReplacementService.get_replacement_services_with_timetables(start_date, end_date)
      render(conn, "index.json-api", data: data)
    else
      {:error, :invalid_date} ->
        conn
        |> put_status(400)
        |> json(%{error: "Invalid date format. Use YYYY-MM-DD"})

      {:error, :invalid_date_order} ->
        conn
        |> put_status(400)
        |> json(%{error: "End date must be after start date"})
    end
  end
end
