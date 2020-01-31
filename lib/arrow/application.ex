defmodule Arrow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    run_migrations_at_startup? = Application.get_env(:arrow, :run_migrations_at_startup?)

    # List all child processes to be supervised
    children =
      [
        # Start the Ecto repository
        Arrow.Repo,
        {Arrow.AdjustmentFetcher, path: Application.app_dir(:arrow, "priv/repo/shuttles.json")},
        # Start the endpoint when the application starts
        ArrowWeb.Endpoint
        # Starts a worker by calling: Arrow.Worker.start_link(arg)
        # {Arrow.Worker, arg},
      ] ++ migrate_children(run_migrations_at_startup?)

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Arrow.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ArrowWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  def migrate_children(true) do
    [Arrow.Repo.Migrator]
  end

  def migrate_children(false) do
    []
  end
end
