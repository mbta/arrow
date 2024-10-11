defmodule Arrow.Gtfs.ValidationWorker do
  @moduledoc """
  Oban worker for GTFS validation jobs.
  """
  use Oban.Worker,
    queue: :gtfs_import,
    # The job is discarded after one failed attempt.
    max_attempts: 1,
    # In config.exs, the :gtfs_import queue is configured to run only 1 job at a time.
    #
    # We also enforce uniqueness by archive version--if an existing validatiopn job is already
    # running or queued on the same archive version, a new job for that same version will fail.
    #
    # It's ok to queue up a validation job for a different version than what's currently
    # running/queued, though.
    unique: [
      fields: [:worker],
      keys: [:archive_version],
      states: Oban.Job.states() -- [:completed, :discarded, :cancelled]
    ]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"s3_uri" => s3_uri, "archive_version" => new_version}}) do
    current_version = "doesn't matter for validation"

    with {:ok, unzip} <- Arrow.Gtfs.Archive.to_unzip_struct(s3_uri) do
      Arrow.Gtfs.import(unzip, current_version, new_version, true)
    end
  end

  # A sane timeout to avoid buildup of stuck jobs.
  # Jobs should take much less than an hour, generally.
  @impl Oban.Worker
  def timeout(_job), do: :timer.hours(1)
end
