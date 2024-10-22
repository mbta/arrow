defmodule Arrow.Gtfs.ImportWorker do
  @moduledoc """
  Oban worker for GTFS import jobs.
  """
  use Oban.Worker,
    queue: :gtfs_import,
    # The job is discarded after one failed attempt.
    max_attempts: 1,
    # In config.exs, the :gtfs_import queue is configured to run only 1 job at a time.
    #
    # We also enforce uniqueness by archive version--if an existing import job is already
    # running or queued on the same archive version, a new job for that same version will fail.
    #
    # It's ok to queue up an import job for a different version than what's currently
    # running/queued, though.
    unique: [
      fields: [:worker, :args],
      keys: [:archive_version],
      states: Oban.Job.states() -- [:completed, :discarded, :cancelled]
    ]

  import Ecto.Query

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"s3_uri" => s3_uri, "archive_version" => new_version}} = job) do
    current_version =
      Arrow.Repo.one(
        from info in Arrow.Gtfs.FeedInfo, where: info.id == "mbta-ma-us", select: info.version
      )

    with {:ok, unzip} <- Arrow.Gtfs.Archive.to_unzip_struct(s3_uri) do
      Arrow.Gtfs.import(unzip, current_version, new_version, job)
    end
  end

  # A sane timeout to avoid buildup of stuck jobs. This is especially important
  # for cases where our RDS instance runs out of credits--it stops the job from
  # eating up additional credits as they recharge and keeping the server
  # unresponsive for even longer.
  # Import jobs generally take around 5 minutes.
  @impl Oban.Worker
  def timeout(_job), do: :timer.minutes(10)

  @spec check_jobs(Arrow.Gtfs.JobHelper.status_filter()) :: list(map)
  def check_jobs(status_filter) do
    Arrow.Gtfs.JobHelper.check_jobs(__MODULE__, status_filter)
  end
end
