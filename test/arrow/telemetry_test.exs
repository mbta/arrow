defmodule Arrow.ExceptionalWorker do
  @moduledoc """
  Worker that raises an exception.
  """
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"arg" => arg}}) do
    raise "argh! arg: #{arg}"
  end
end

defmodule Arrow.TelemetryTest do
  @moduledoc false
  use ExUnit.Case, async: true
  use Oban.Testing, repo: Arrow.Repo

  import ExUnit.CaptureLog

  describe "oban.job.exception listener" do
    test "logs exception info" do
      log =
        capture_log([level: :warning], fn ->
          try do
            perform_job(Arrow.ExceptionalWorker, %{
              arg: "argyle gargoyle"
            })
          rescue
            _ -> nil
          end
        end)

      assert log =~ "Oban job exception"
      assert log =~ ~s|message="argh! arg: argyle gargoyle"|
    end
  end
end
