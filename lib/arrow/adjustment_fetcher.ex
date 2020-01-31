defmodule Arrow.AdjustmentFetcher do
  @moduledoc """
  Reads in information on what adjustments are present in GTFS Creator
  and saves them to the database. Currently reads from the `priv`
  directory once on startup, but eventually this will poll some sort
  of API on a regular basis.
  """

  use GenServer, restart: :transient

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts \\ []) do
    :ok =
      opts[:path]
      |> File.read!()
      |> Jason.decode!()
      |> update_adjustment_data!()

    :ignore
  end

  @spec update_adjustment_data!(map()) :: :ok
  defp update_adjustment_data!(parsed_adjustments) do
    timestamp = DateTime.truncate(DateTime.utc_now(), :second)

    adjustments =
      Enum.map(parsed_adjustments, fn parsed_adjustment ->
        %{
          source: "gtfs_creator",
          source_label: parsed_adjustment["id"],
          route_id: parsed_adjustment["attributes"]["route_id"],
          inserted_at: timestamp,
          updated_at: timestamp
        }
      end)

    {_, _} =
      Arrow.Repo.insert_all(Arrow.Adjustment, adjustments,
        on_conflict: [set: [source: "gtfs_creator"]],
        conflict_target: :source_label
      )

    :ok
  end
end
