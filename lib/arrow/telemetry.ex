defmodule Arrow.Telemetry do
  @moduledoc """
  Telemetry listeners for Arrow business logic.
  """
  require Logger

  @spec setup_telemetry() :: :ok
  def setup_telemetry do
    _ =
      :telemetry.attach_many(
        "oban",
        [[:oban, :job, :start], [:oban, :job, :stop], [:oban, :job, :exception]],
        # telemetry prefers event handler to be passed as a non-local function
        # capture--i.e., with module name included--for performance reasons.
        &Arrow.Telemetry.handle_event/4,
        []
      )

    :ok
  end

  def handle_event(event, measures, meta, config)

  def handle_event([:oban, :job, :start], _measures, meta, _config) do
    Logger.info("Oban job started #{get_job_info(meta.job)}")
  end

  def handle_event([:oban, :job, :stop], measures, meta, _config) do
    Logger.info(
      "Oban job stopped #{get_job_info(meta.job)} state=#{meta.state} result=#{inspect(meta.result)} duration=#{measures.duration} memory=#{measures.memory} queue_time=#{measures.queue_time}"
    )
  end

  def handle_event([:oban, :job, :exception], measures, meta, _config) do
    details =
      case meta.kind do
        :error ->
          message = Exception.message(meta.reason)
          full_details = Exception.format(meta.kind, meta.reason, meta.stacktrace)
          "message=#{message}\n#{full_details}"

        _other ->
          "\n#{Exception.format(meta.kind, meta.reason, meta.stacktrace)}"
      end

    Logger.warn(
      "Oban job exception #{get_job_info(meta.job)} state=#{meta.state} result=#{inspect(meta.result)} duration=#{measures.duration} memory=#{measures.memory} queue_time=#{measures.queue_time} #{details}"
    )
  end

  @gtfs_workers [inspect(Arrow.Gtfs.ImportWorker), inspect(Arrow.Gtfs.ValidationWorker)]

  defp get_job_info(%Oban.Job{worker: worker} = job) when worker in @gtfs_workers do
    Arrow.Gtfs.JobHelper.logging_params(job)
  end

  defp get_job_info(job) do
    "job_id=#{job.id} job_args=#{inspect(job.args)} job_worker=#{inspect(job.worker)}"
  end
end
