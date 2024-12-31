defmodule Arrow.AdjustmentFetcher do
  @moduledoc """
  Periodically copies the list of adjustments available in gtfs_creator into the database. These
  are uploaded to S3 as part of the gtfs_creator deploy process.
  """

  use GenServer

  import Ecto.Query, only: [from: 2]

  require Logger

  @fetch_interval_ms 5 * 60 * 1000

  @spec start_link(Keyword.t()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [])
  end

  @impl true
  def init(opts) do
    interval = Keyword.get(opts, :interval, @fetch_interval_ms)
    Process.send_after(self(), :fetch, interval)
    {:ok, interval}
  end

  @impl true
  def handle_info(:fetch, interval) do
    _ = Logger.debug("adjustment_fetch_started")

    _ =
      case fetch() do
        :ok -> Logger.debug("adjustment_fetch_complete")
        {:error, reason} -> Logger.warning("adjustment_fetch_failed: #{inspect(reason)}")
      end

    Process.send_after(self(), :fetch, interval)
    {:noreply, interval}
  end

  @spec fetch() :: :ok | {:error, any()}
  def fetch do
    http = Application.get_env(:arrow, :http_client)
    url = Application.get_env(:arrow, :adjustments_url)

    with {:ok, %{status_code: 200, body: body}} <- http.get(url),
         {:ok, adjustments} <- Jason.decode(body) do
      :ok = update_adjustment_data!(adjustments)
    else
      {_, result} -> {:error, result}
    end
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

    adjustment_source_labels = Enum.map(adjustments, & &1.source_label)

    unused_adjustment_ids =
      Arrow.Repo.all(
        from d in Arrow.DisruptionRevision,
          right_join: a in assoc(d, :adjustments),
          select: a.id,
          where: is_nil(d.id)
      )

    Arrow.Repo.delete_all(
      from(
        a in Arrow.Adjustment,
        where:
          a.source == "gtfs_creator" and a.source_label not in ^adjustment_source_labels and
            a.id in ^unused_adjustment_ids
      )
    )

    :ok
  end
end
