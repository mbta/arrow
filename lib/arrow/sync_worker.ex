defmodule Arrow.SyncWorker do
  @moduledoc """
  Oban worker for syncing stops and shapes from production to development environment.

  This worker is only scheduled to run hourly when ARROW_SYNC_ENABLED=true. When running:
  - Fetches stops from prod API and creates any missing ones (by stop_id)
  - Fetches shapes from prod API and creates any missing ones (by name)
  - Downloads KML files, parses them using ShapesUpload, and creates shapes via Shuttles.create_shape/1
  """

  use Oban.Worker,
    queue: :default,
    max_attempts: 3,
    # Prevent duplicate jobs within an hour
    unique: [period: 3600]

  alias Arrow.{Repo, Shuttles, Stops}
  alias Arrow.Shuttles.{Shape, ShapesUpload, Stop}

  require Logger
  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("Starting prod-to-dev sync")

    with :ok <- sync_stops(),
         :ok <- sync_shapes() do
      Logger.info("Sync completed successfully")
      :ok
    else
      {:error, reason} ->
        Logger.error("Sync failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @impl Oban.Worker
  def timeout(_job), do: :timer.minutes(10)

  defp sync_stops do
    Logger.info("Starting stops sync")

    case fetch_prod_data("/api/shuttle-stops") do
      {:ok, %{"data" => stops_data}} ->
        existing_stop_ids =
          from(s in Stop, select: s.stop_id)
          |> Repo.all()
          |> MapSet.new()

        new_stops =
          stops_data
          |> Enum.reject(fn stop -> stop["attributes"]["stop_id"] in existing_stop_ids end)

        sync_results = new_stops |> Enum.map(&create_stop_from_api_data/1) |> Enum.frequencies()

        Logger.info("Stops sync: #{sync_results[:ok]} created, #{sync_results[:error]} errors")
        :ok

      {:error, reason} ->
        Logger.error("Failed to fetch stops from prod API: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp sync_shapes do
    Logger.info("Starting shapes sync")

    case fetch_prod_data("/api/shapes") do
      {:ok, %{"data" => shapes_data}} ->
        existing_shape_names =
          from(s in Shape, select: s.name)
          |> Repo.all()
          |> MapSet.new()

        new_shapes =
          shapes_data
          |> Enum.reject(fn shape -> shape["attributes"]["name"] in existing_shape_names end)

        sync_results = new_shapes |> Enum.map(&create_shape_from_api_data/1) |> Enum.frequencies()

        Logger.info("Shapes sync: #{sync_results[:ok]} created, #{sync_results[:error]} errors")
        :ok

      {:error, reason} ->
        Logger.error("Failed to fetch shapes from prod API: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp fetch_prod_data(endpoint) do
    domain = Application.get_env(:arrow, :sync_domain)
    api_key = Application.get_env(:arrow, :sync_api_key)
    http_client = Application.get_env(:arrow, :http_client)

    url = "#{domain}#{endpoint}"
    headers = ["x-api-key": api_key, accept: "application/vnd.api+json"]

    case http_client.get(url, headers) do
      {:ok, %{status_code: 200, body: body}} ->
        Jason.decode(body)

      {:ok, %{status_code: status_code}} ->
        {:error, "HTTP #{status_code}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_stop_from_api_data(%{"attributes" => attributes}) do
    stop_params =
      %{
        stop_id: attributes["stop_id"],
        stop_name: attributes["stop_name"],
        stop_desc: attributes["stop_desc"],
        platform_code: attributes["platform_code"],
        platform_name: attributes["platform_name"],
        stop_lat: attributes["stop_lat"],
        stop_lon: attributes["stop_lon"],
        stop_address: attributes["stop_address"],
        zone_id: attributes["zone_id"],
        level_id: attributes["level_id"],
        parent_station: attributes["parent_station"],
        municipality: attributes["municipality"],
        on_street: attributes["on_street"],
        at_street: attributes["at_street"]
      }
      |> Map.new()

    case Stops.create_stop(stop_params) do
      {:ok, stop} ->
        Logger.info("Created stop: #{stop.stop_id}")
        :ok

      {:error, changeset} ->
        error_msg = inspect(changeset.errors)
        Logger.error("Failed to create stop #{stop_params[:stop_id]}: #{error_msg}")
        :error
    end
  end

  defp create_shape_from_api_data(%{"attributes" => attributes}) do
    shape_name = attributes["name"]
    download_url = attributes["download_url"]

    with {:ok, kml_content} <- download_kml_file(download_url),
         {:ok, parsed_kml} <- ShapesUpload.parse_kml(kml_content),
         {:ok, [%{name: _name, coordinates: coordinates}]} <-
           ShapesUpload.shapes_from_kml(parsed_kml),
         {:ok, _shape} <-
           Shuttles.create_shape(
             %{name: shape_name, coordinates: Enum.join(coordinates, " ")},
             # don't enforce naming conventions on shapes synced from prod
             false
           ) do
      Logger.info("Created shape: #{shape_name}")
      :ok
    else
      {:error, reason} ->
        error_msg = "Failed to create shape #{shape_name}: #{inspect(reason)}"
        Logger.error(error_msg)
        :error
    end
  end

  defp download_kml_file(url) do
    http_client = Application.get_env(:arrow, :http_client)

    case http_client.get(url) do
      {:ok, %{status_code: 200, body: kml_content}} ->
        {:ok, kml_content}

      {:ok, %{status_code: status_code}} ->
        {:error, "HTTP #{status_code} when downloading KML"}

      {:error, reason} ->
        {:error, "Download failed: #{inspect(reason)}"}
    end
  end
end
