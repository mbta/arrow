defmodule ArrowWeb.Telemetry do
  @moduledoc """
  Provides data for the LiveDashboard "metrics" tab.
  """

  use Supervisor

  import Telemetry.Metrics

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      # Telemetry poller will execute the given period measurements
      # every 10_000ms. Learn more here: https://hexdocs.pm/telemetry_metrics
      {:telemetry_poller, measurements: periodic_measurements(), period: 10_000}
      # Add reporters as children of your supervision tree.
      # {Telemetry.Metrics.ConsoleReporter, metrics: metrics()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def metrics do
    [
      # Phoenix Metrics
      summary("phoenix.endpoint.stop.duration",
        unit: {:native, :millisecond}
      ),
      summary("phoenix.router_dispatch.stop.duration",
        tags: [:route],
        unit: {:native, :millisecond}
      ),

      # Database Time Metrics
      summary("arrow.repo.query.total_time", unit: {:native, :millisecond}),
      summary("arrow.repo.query.decode_time", unit: {:native, :millisecond}),
      summary("arrow.repo.query.query_time", unit: {:native, :millisecond}),
      summary("arrow.repo.query.queue_time", unit: {:native, :millisecond}),
      summary("arrow.repo.query.idle_time", unit: {:native, :millisecond}),

      # VM Metrics
      summary("vm.memory.total", unit: {:byte, :kilobyte}),
      summary("vm.total_run_queue_lengths.total"),
      summary("vm.total_run_queue_lengths.cpu"),
      summary("vm.total_run_queue_lengths.io"),

      # Oban metrics
      # fetch_jobs
      counter("oban.engine.fetch_jobs.start.system_time"),
      summary("oban.engine.fetch_jobs.stop.duration"),
      summary("oban.engine.fetch_jobs.exception.duration"),
      # retry_all_jobs
      counter("oban.engine.retry_all_jobs.start.system_time"),
      summary("oban.engine.retry_all_jobs.stop.duration"),
      summary("oban.engine.retry_all_jobs.exception.duration"),
      # stage_jobs
      counter("oban.engine.stage_jobs.start.system_time"),
      summary("oban.engine.stage_jobs.stop.duration"),
      summary("oban.engine.stage_jobs.exception.duration"),
      # cancel_job
      counter("oban.engine.cancel_job.start.system_time"),
      summary("oban.engine.cancel_job.stop.duration"),
      summary("oban.engine.cancel_job.exception.duration"),
      # complete_job
      counter("oban.engine.complete_job.start.system_time"),
      summary("oban.engine.complete_job.stop.duration"),
      summary("oban.engine.complete_job.exception.duration"),
      # discard_job
      counter("oban.engine.discard_job.start.system_time"),
      summary("oban.engine.discard_job.stop.duration"),
      summary("oban.engine.discard_job.exception.duration"),
      # error_job
      counter("oban.engine.error_job.start.system_time"),
      summary("oban.engine.error_job.stop.duration"),
      summary("oban.engine.error_job.exception.duration"),
      # insert_job
      counter("oban.engine.insert_job.start.system_time"),
      summary("oban.engine.insert_job.stop.duration"),
      summary("oban.engine.insert_job.exception.duration"),
      # retry_job
      counter("oban.engine.retry_job.start.system_time"),
      summary("oban.engine.retry_job.stop.duration"),
      summary("oban.engine.retry_job.exception.duration"),
      # snooze_job
      counter("oban.engine.snooze_job.start.system_time"),
      summary("oban.engine.snooze_job.stop.duration"),
      summary("oban.engine.snooze_job.exception.duration"),
      # notifier.notify
      counter("oban.notifier.notify.start.system_time"),
      summary("oban.notifier.notify.stop.duration"),
      summary("oban.notifier.notify.exception.duration")
    ]
  end

  defp periodic_measurements do
    []
  end
end
