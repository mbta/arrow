defmodule Arrow.Gtfs.JobHelper do
  @moduledoc """
  Utilities for Oban jobs.
  """
  import Ecto.Query

  @typedoc """
  Filters for `check_jobs/2`.

  - `:all`       - Do not filter results
  - `:queued`    - Jobs with status "scheduled" or "available"
  - `:executing` - Jobs with status "executing" or "retryable"
  - `:succeeded` - Jobs with status "completed"
  - `:failed`    - Jobs with status "discarded"
  - `:cancelled` - Jobs with status "cancelled"
  - `:not_done`  - Jobs with status "scheduled", "available", "executing", or "retryable"
  - `:done`      - Jobs with status "completed", "discarded", or "cancelled"
  """
  @type status_filter ::
          :all | :queued | :executing | :succeeded | :failed | :cancelled | :not_done | :done

  @doc """
  Returns details about GTFS import jobs.
  """
  @spec check_jobs(module, status_filter) :: list(map)
  def check_jobs(worker_mod, status_filter) do
    worker = inspect(worker_mod)
    states = Map.fetch!(job_filters(), status_filter)

    Arrow.Repo.all(from j in Oban.Job, where: [worker: ^worker], where: j.state in ^states)
    |> Enum.map(
      &Map.take(
        &1,
        ~w[id state queue worker args errors tags attempt attempted_by max_attempts priority inserted_at scheduled_at attempted_at completed_at discarded_at cancelled_at]a
      )
    )
  end

  defp job_filters do
    %{
      all: Enum.map(Oban.Job.states(), &Atom.to_string/1),
      queued: ~w[scheduled available],
      executing: ~w[executing retryable],
      succeeded: ~w[completed],
      failed: ~w[discarded],
      cancelled: ~w[cancelled],
      not_done: ~w[scheduled available executing retryable],
      done: ~w[completed discarded cancelled]
    }
  end
end
