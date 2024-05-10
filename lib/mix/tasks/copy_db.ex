defmodule Mix.Tasks.CopyDb do
  @moduledoc """
  Mix task to clone the Arrow database (dev or prod) in AWS locally.
  """

  use Mix.Task
  require Logger

  @shortdoc "Copies database"
  @impl Mix.Task
  def run(_args) do
    api_key = System.get_env("ARROW_API_KEY")
    domain = System.get_env("ARROW_DOMAIN", "https://arrow.mbta.com")
    fetch_module = Application.get_env(:arrow, :http_client)

    Ecto.Migrator.with_repo(Arrow.Repo, fn repo ->
      {:ok, _} = fetch_module.start()

      with %{status_code: 200, body: body} <-
             fetch_module.get!("#{domain}/api/db_dump",
               "x-api-key": api_key
             ),
           {:ok, data} <- Jason.decode(body) do
        data =
          Map.new(data, fn {table, data} ->
            {table,
             Enum.map(data, fn map ->
               Map.new(map, fn {key, value} ->
                 parsed_value = parse_json_value(value)

                 {String.to_existing_atom(key), parsed_value}
               end)
             end)}
          end)

        :ok = Arrow.DBStructure.load_data(repo, data)
      else
        err ->
          Logger.error("Error parsing response data: #{get_error(err)}")
      end
    end)
  end

  defp get_error({:error, %Jason.DecodeError{}}), do: "invalid JSON"
  defp get_error(%{status_code: status_code}), do: "issue with request: #{status_code}"

  @spec parse_json_value(any()) :: any()
  defp parse_json_value(value) do
    cond do
      not is_binary(value) ->
        value

      match?({:ok, _, _}, DateTime.from_iso8601(value)) ->
        {:ok, dt, _} = DateTime.from_iso8601(value)
        dt

      match?({:ok, _}, Date.from_iso8601(value)) ->
        {:ok, d} = Date.from_iso8601(value)
        d

      match?({:ok, _}, Time.from_iso8601(value)) ->
        {:ok, t} = Time.from_iso8601(value)
        t

      true ->
        value
    end
  end
end
