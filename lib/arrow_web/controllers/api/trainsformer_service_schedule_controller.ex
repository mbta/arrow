defmodule ArrowWeb.API.TrainsformerServiceScheduleController do
  use ArrowWeb, :controller

  alias ArrowWeb.API.Util

  def index(conn, params) do
    with {:ok, start_date} <- parse_date_param(params, "start_date", conn),
         {:ok, end_date} <- parse_date_param(params, "end_date", conn),
         :ok <- validate_date_order(start_date, end_date, conn) do
      trainsformer_exports =
        Arrow.Trainsformer.list_service_schedules(start_date: start_date, end_date: end_date)

      response_body =
        for export <- trainsformer_exports do
          {:ok, download_url} = Arrow.Trainsformer.export_download_url(export)

          services =
            for service <- export.services do
              %{
                service_id: service.id,
                service_name: service.name,
                date_ranges:
                  Enum.map(
                    service.service_dates,
                    &%{
                      start_date: &1.start_date,
                      end_date: &1.end_date
                    }
                  )
              }
            end

          %{
            trainsformer_export_id: export.id,
            disruption_id: export.disruption_id,
            disruption_title: export.disruption.title,
            services: services,
            download_url: download_url
          }
        end

      conn
      |> json(response_body)
    end
  end

  defp parse_date_param(params, name, conn) do
    case Util.parse_date(Map.get(params, name)) do
      {:ok, date} ->
        {:ok, date}

      _ ->
        conn
        |> put_status(400)
        |> json(%{error: "`#{name}` is not a valid date"})
    end
  end

  defp validate_date_order(start_date, end_date, conn) do
    case Util.validate_date_order(start_date, end_date) do
      :ok ->
        :ok

      _ ->
        conn
        |> put_status(409)
        |> json(%{error: "`end_date` must be after `start_date`"})
    end
  end
end
