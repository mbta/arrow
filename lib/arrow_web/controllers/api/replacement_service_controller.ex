defmodule ArrowWeb.API.ReplacementServiceController do
  use ArrowWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Repo
  alias ArrowWeb.API.Util
  alias Plug.Conn

  @spec index(Conn.t(), map()) :: Conn.t()
  def index(conn, params) do
    with {:ok, start_date} <- Util.parse_date(params["start_date"]),
         {:ok, end_date} <- Util.parse_date(params["end_date"]),
         :ok <- Util.validate_date_order(start_date, end_date) do
      data =
        from(r in ReplacementService,
          # where: r.start_date >= ^start_date and r.end_date <= ^end_date,
          join: s in assoc(r, :shuttle),
          join: d in assoc(r, :disruption),
          join: sr in assoc(s, :routes),
          join: rs in assoc(sr, :route_stops),
          left_join: gs in assoc(rs, :gtfs_stop),
          left_join: st in assoc(rs, :stop),
          where: r.start_date <= ^end_date and r.end_date >= ^start_date,
          preload: [:disruption, shuttle: {s, routes: {sr, route_stops: [:gtfs_stop, :stop]}}]
        )
        |> Repo.all()
        |> Enum.map(fn rs ->
          Map.from_struct(rs)
          |> Map.put(
            :timetable,
            ReplacementService.schedule_service_types()
            |> Enum.map(fn service_type ->
              {service_type, ReplacementService.trips_with_times(rs, service_type)}
            end)
            |> Enum.into(%{})
          )
        end)

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
