defmodule Arrow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # Invoke Sentry logger:
    _ = Logger.add_backend(Sentry.LoggerBackend)

    run_adjustment_fetcher? = Application.get_env(:arrow, :fetch_adjustments?)
    run_migrations_at_startup? = Application.get_env(:arrow, :run_migrations_at_startup?)

    # List all child processes to be supervised
    children =
      [
        # Start the PubSub system
        {Phoenix.PubSub, name: Arrow.PubSub},
        # Start the Ecto repository
        Arrow.Repo,
        # Start the endpoint when the application starts
        ArrowWeb.Endpoint
      ] ++
        migrate_children(run_migrations_at_startup?) ++
        adjustment_fetcher_children(run_adjustment_fetcher?)

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
    migrate_synchronously? = Application.get_env(:arrow, :migrate_synchronously?)
    [{Arrow.Repo.Migrator, [migrate_synchronously?: migrate_synchronously?]}]
  end

  def migrate_children(false) do
    []
  end

  def adjustment_fetcher_children(true) do
    [{Arrow.AdjustmentFetcher, []}]
  end

  def adjustment_fetcher_children(false) do
    []
  end
end
