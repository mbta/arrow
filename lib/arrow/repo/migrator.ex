defmodule Arrow.Repo.Migrator do
  @moduledoc """
  GenServer which runs on startup to run Ecto migrations, then terminates.
  """
  use GenServer, restart: :transient
  require Logger

  @opts [module: Ecto.Migrator]

  def start_link(opts) do
    opts = Keyword.merge(@opts, opts)
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    {:ok, opts, {:continue, :migrate}}
  end

  @impl GenServer
  def handle_continue(:migrate, opts) do
    migrate!(opts[:module])
    {:stop, :normal, opts}
  end

  defp migrate!(module) do
    for repo <- repos() do
      _ = Logger.info(fn -> "Migrating repo=#{repo}" end)

      {time_usec, {:ok, _, _}} =
        :timer.tc(module, :with_repo, [repo, &module.run(&1, :up, all: true)])

      time_msec = System.convert_time_unit(time_usec, :microsecond, :millisecond)
      _ = Logger.info(fn -> "Migration finished repo=#{repo} time=#{time_msec}" end)
    end

    :ok
  end

  defp repos do
    Application.fetch_env!(:arrow, :ecto_repos)
  end
end
