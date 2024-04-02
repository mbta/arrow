defmodule Arrow.MixProject do
  use Mix.Project

  def project do
    [
      app: :arrow,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_add_deps: :transitive,
        flags: [
          :unmatched_returns
        ],
        ignore_warnings: ".dialyzer.ignore-warnings"
      ],
      preferred_cli_env: ["test.integration": :test],
      test_coverage: [tool: LcovEx, ignore_paths: ["deps/"]]
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
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.11"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:ex_aws_rds, "~> 2.0"},
      {:ex_aws_secretsmanager, "~> 2.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_machina, "~> 2.3", only: :test},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:httpoison, "~> 1.6"},
      {:ja_serializer, github: "mbta/ja_serializer", branch: "master"},
      {:jason, "~> 1.0"},
      {:lcov_ex, "~> 0.2", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: :test},
      {:phoenix_ecto, "~> 4.0"},
      # override for react_phoenix, pending
      # https://github.com/geolessel/react-phoenix/pull/58
      {:phoenix_html, "~> 3.2.0", override: true},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.16.4"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix, "~> 1.6.0"},
      {:plug_cowboy, "~> 2.1"},
      {:telemetry, "~> 1.2", override: true},
      {:postgrex, ">= 0.0.0"},
      # If react_phoenix changes, check assets/src/ReactPhoenix.js, too
      {:react_phoenix, "1.2.0"},
      {:tzdata, "~> 1.1"},
      {:ueberauth_cognito, "0.4.0"},
      {:ueberauth_oidcc, "~> 0.3.2"},
      {:ueberauth, "~> 0.10"},
      {:wallaby, "~> 0.30.6", runtime: false, only: :test},
      {:sentry, "~> 8.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create and migrate at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.migrate": ["ecto.migrate", "ecto.dump --quiet"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.rollback": ["ecto.rollback", "ecto.dump --quiet"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.build": ["esbuild default --sourcemap=inline"],
      "assets.deploy": ["esbuild default --minify", "phx.digest"],
      "test.integration": [
        "assets.build",
        "ecto.create --quiet",
        "ecto.migrate --quiet",
        "test --only integration"
      ]
    ]
  end

  defp releases do
    [
      arrow: [
        include_executables_for: [:unix]
      ]
    ]
  end
end
