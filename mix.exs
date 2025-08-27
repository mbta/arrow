defmodule Arrow.MixProject do
  use Mix.Project

  def project do
    [
      app: :arrow,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: releases(),
      dialyzer: [
        plt_add_apps: [:mix],
        plt_add_deps: :app_tree,
        flags: [
          :unmatched_returns
        ]
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
  def deps do
    [
      {:typed_ecto_schema, "~> 0.4.3"},
      {:ex_doc, "~> 0.38.3", only: :dev, runtime: false, warn_if_outdated: true},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:csv, "~> 3.2"},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ecto_sql, "~> 3.11"},
      {:ecto_psql_extras, "~> 0.6"},
      {:esbuild, "~> 0.2", runtime: Mix.env() == :dev},
      {:ex_aws_rds, "~> 2.0"},
      {:ex_aws_secretsmanager, "~> 2.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.1"},
      {:sweet_xml, "~> 0.7.4"},
      {:ex_machina, "~> 2.8", only: :test},
      {:gettext, "~> 0.11"},
      {:guardian, "~> 2.0"},
      {:hackney, "~> 1.21"},
      {:httpoison, "~> 2.2"},
      {:ja_serializer, "~> 0.18.0"},
      {:jason, "~> 1.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:live_select, "~> 1.6.0"},
      {:lcov_ex, "~> 0.2", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.2", only: :test},
      {:oban, "~> 2.18"},
      {:phoenix_ecto, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_html_helpers, "~> 1.0"},
      {:phoenix_live_react, "~> 0.6"},
      {:phoenix_live_view, "~> 1.1.2"},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix, "~> 1.7.12"},
      {:plug_cowboy, "~> 2.1"},
      {:telemetry, "~> 1.2", override: true},
      {:telemetry_poller, "~> 1.1"},
      {:telemetry_metrics, "~> 1.0"},
      {:postgrex, ">= 0.0.0"},
      # If react_phoenix changes, check assets/src/ReactPhoenix.js, too
      {:react_phoenix, git: "https://github.com/mbta/react-phoenix.git"},
      {:tzdata, "~> 1.1"},
      {:ueberauth_oidcc, "~> 0.4.0"},
      {:ueberauth, "~> 0.10"},
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      {:sentry, "~> 10.7"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false},
      {:sax_map, "~> 1.2"},
      {:unzip, "~> 0.12.0"},
      {:xlsxir, "~> 1.6"}
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
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["esbuild default --sourcemap=inline", "tailwind default"],
      "assets.deploy": ["esbuild default --minify", "tailwind default --minify", "phx.digest"],
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
