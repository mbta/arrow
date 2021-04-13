defmodule FakeMigrator do
  @moduledoc "Fake implementation of Ecto.Migrator"
  def with_repo(repo, fun) do
    :ok = fun.(repo)
    {:ok, :ok, :ok}
  end

  def run(Arrow.Repo, :up, all: true) do
    :ok
  end
end

defmodule Arrow.Repo.MigratorTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog

  alias Arrow.Repo.Migrator

  describe "child_spec/1" do
    test "restart is transient" do
      assert %{
               restart: :transient
             } = Migrator.child_spec([])
    end
  end

  describe "start_link/1" do
    test "can start the server" do
      assert {:ok, _pid} = Migrator.start_link(module: FakeMigrator)
    end

    test "runs migrations and ends when run synchronously" do
      log_level_info()

      log =
        capture_log(fn ->
          assert :ignore = Migrator.start_link(module: FakeMigrator, migrate_synchronously?: true)
        end)

      assert log =~ "Migrating synchronously"
    end

    test "logs a migration for each repo" do
      log_level_info()

      log =
        capture_log(fn ->
          {:ok, pid} = Migrator.start_link(module: FakeMigrator)
          :ok = await_stopped(pid)
        end)

      assert log =~ "Migrating"
      assert log =~ "Migration finished"
      assert log =~ "repo=Elixir.Arrow.Repo"
      assert log =~ "time="
    end
  end

  defp log_level_info() do
    old_level = Logger.level()

    on_exit(fn ->
      Logger.configure(level: old_level)
    end)

    Logger.configure(level: :info)

    :ok
  end

  defp await_stopped(pid) do
    ref = Process.monitor(pid)

    receive do
      {:DOWN, ^ref, :process, ^pid, good_exit} when good_exit in [:normal, :noproc] ->
        refute Process.alive?(pid)
        :ok

      {:DOWN, ^ref, :process, ^pid, exit} ->
        {:error, exit}
    after
      5_000 ->
        {:error, :timeout}
    end
  end
end
