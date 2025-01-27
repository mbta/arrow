defmodule ArrowWeb.API.LimitController do
  use ArrowWeb, :controller

  alias Arrow.Disruptions

  def index(conn, params) do
    with {:ok, start_date} <- parse_date(params["start_date"]),
         {:ok, end_date} <- parse_date(params["end_date"]),
         :ok <- validate_date_order(start_date, end_date) do
      limits = Disruptions.get_limits_in_date_range(start_date, end_date)
      render(conn, "index.json-api", data: limits)
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

  defp parse_date(nil), do: {:error, :invalid_date}

  defp parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, :invalid_date}
    end
  end

  defp validate_date_order(start_date, end_date) do
    if Date.compare(end_date, start_date) in [:gt, :eq] do
      :ok
    else
      {:error, :invalid_date_order}
    end
  end
end
