defmodule ArrowWeb.API.Util do
  @spec parse_date(String.t()) :: {:ok, Date.t()} | {:error, :invalid_date}
  def parse_date(nil), do: {:error, :invalid_date}
  def parse_date(date_string) do
    case Date.from_iso8601(date_string) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, :invalid_date}
    end
  end

  @spec validate_date_order(Date.t(), Date.t()) :: :ok | {:error, :invalid_date_order}
  def validate_date_order(start_date, end_date) do
    if Date.compare(end_date, start_date) in [:gt, :eq] do
      :ok
    else
      {:error, :invalid_date_order}
    end
  end
end
