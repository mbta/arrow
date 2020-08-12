defmodule Mix.Tasks.CopyDb do
  use Mix.Task
  import Ecto.Query
  require Logger

  @shortdoc "Copies database"
  @impl Mix.Task
  def run(_args) do
    api_key = System.get_env("ARROW_API_KEY")
    domain = System.get_env("ARROW_DOMAIN", "https://arrow-dev.mbtace.com")
    fetch_module = Application.get_env(:arrow, :http_client)

    Ecto.Migrator.with_repo(Arrow.Repo, fn repo ->
      {:ok, _} = fetch_module.start()
      now = DateTime.utc_now() |> DateTime.truncate(:second)

      with %{status_code: 200, body: adj_body} <-
             fetch_module.get!("#{domain}/api/adjustments",
               "x-api-key": api_key
             ),
           {:ok, %{"data" => adjustments}} <- Jason.decode(adj_body),
           %{status_code: 200, body: dis_body} <-
             fetch_module.get!("#{domain}/api/disruptions",
               "x-api-key": api_key
             ),
           {:ok, %{"data" => disruptions, "included" => disruption_relations}} <-
             Jason.decode(dis_body) do
        relations =
          Enum.reduce(disruption_relations, %{}, fn x, acc ->
            Map.put(acc, {x["type"], x["id"]}, x["attributes"])
          end)

        adjustments =
          Enum.map(adjustments, fn x ->
            %{
              id: String.to_integer(x["id"]),
              route_id: x["attributes"]["route_id"],
              source: x["attributes"]["source"],
              source_label: x["attributes"]["source_label"],
              inserted_at: now,
              updated_at: now
            }
          end)

        disruptions =
          Enum.map(disruptions, fn x ->
            attrs = x["attributes"]
            relationships = x["relationships"]

            adjustment_ids =
              Enum.map(relationships["adjustments"]["data"], fn x ->
                String.to_integer(x["id"])
              end)

            revision = %Arrow.DisruptionRevision{
              start_date: Date.from_iso8601!(attrs["start_date"]),
              end_date: Date.from_iso8601!(attrs["end_date"]),
              adjustments:
                repo.all(
                  from(adj in Arrow.Adjustment,
                    where: adj.id in ^adjustment_ids
                  )
                ),
              exceptions:
                Enum.map(relationships["exceptions"]["data"], fn x ->
                  data = Map.get(relations, {x["type"], x["id"]})

                  %{
                    id: String.to_integer(x["id"]),
                    excluded_date: Date.from_iso8601!(data["excluded_date"])
                  }
                end),
              trip_short_names:
                Enum.map(relationships["trip_short_names"]["data"], fn x ->
                  data = Map.get(relations, {x["type"], x["id"]})

                  %{
                    id: String.to_integer(x["id"]),
                    trip_short_name: data["trip_short_name"]
                  }
                end),
              days_of_week:
                Enum.map(relationships["days_of_week"]["data"], fn x ->
                  data = Map.get(relations, {x["type"], x["id"]})

                  %{
                    id: String.to_integer(x["id"]),
                    day_name: data["day_name"],
                    start_time:
                      if(data["start_time"], do: Time.from_iso8601!(data["start_time"]), else: nil),
                    end_time:
                      if(data["end_time"], do: Time.from_iso8601!(data["end_time"]), else: nil)
                  }
                end)
            }

            {String.to_integer(x["id"]), revision}
          end)

        operations =
          Ecto.Multi.new()
          |> Ecto.Multi.update_all(:unpublish, Arrow.Disruption, set: [published_revision_id: nil])
          |> Ecto.Multi.delete_all(:delete_revisions, Arrow.DisruptionRevision)
          |> Ecto.Multi.delete_all(:delete_disruptions, Arrow.Disruption)
          |> Ecto.Multi.delete_all(:delete_adjustments, Arrow.Adjustment)
          |> Ecto.Multi.insert_all(:insert_adjustments, Arrow.Adjustment, adjustments,
            on_conflict: :replace_all,
            conflict_target: :source_label
          )

        operations =
          Enum.reduce(disruptions, operations, fn {disruption_id, revision}, acc ->
            Ecto.Multi.run(acc, disruption_id, fn repo, _change_map ->
              d = repo.insert!(%Arrow.Disruption{id: disruption_id})
              dr = repo.insert!(%{revision | disruption_id: d.id})
              d = repo.update!(Ecto.Changeset.change(d, %{published_revision_id: dr.id}))

              {:ok, d}
            end)
          end)

        try do
          repo.transaction(operations)
        rescue
          err ->
            Logger.error("Error inserting data: #{IO.inspect(get_error(err))}")
        end
      else
        err ->
          Logger.error("Error parsing response data: #{IO.inspect(get_error(err))}")
      end
    end)
  end

  defp get_error(%Postgrex.Error{postgres: %{message: err}}), do: err
  defp get_error({:error, %Jason.DecodeError{}}), do: "invalid JSON"
  defp get_error(%{status_code: status_code}), do: "issue with request: #{status_code}"
end
