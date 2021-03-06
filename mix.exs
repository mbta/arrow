defmodule Arrow.MixProject do
  use Mix.Project

  def project do
    [
      app: :arrow,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_add_deps: :transitive,
        flags: [
          :race_conditions,
          :unmatched_returns
        ],
        ignore_warnings: ".dialyzer.ignore-warnings"
      ],
      test_coverage: [tool: LcovEx]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Arrow.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_rds, "~> 2.0"},
      {:ex_aws_secretsmanager, "~> 2.0"},
      {:ex_machina, "~> 2.3", only: :test},
      {:lcov_ex, "~> 0.2", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: :test},
      {:phoenix, "~> 1.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.1"},
      {:hackney, "~> 1.9"},
      {:httpoison, "~> 1.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:ja_serializer, github: "mbta/ja_serializer", branch: "master"},
      {:plug_cowboy, "~> 2.1"},
      {:guardian, "~> 2.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_cognito, "~> 0.1"},
      {:tzdata, "~> 1.1"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp releases do
    [
      arrow: [
        include_executables_for: [:unix],
        config_providers: [{Arrow.SecretsProvider, []}]
      ]
    ]
  end
end
