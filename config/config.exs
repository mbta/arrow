# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# 12 hours in seconds
max_session_time = 12 * 60 * 60

# Addresses an issue with Oban
# https://github.com/oban-bg/oban/issues/493#issuecomment-1187001822
config :arrow, Arrow.Repo,
  parameters: [
    tcp_keepalives_idle: "60",
    tcp_keepalives_interval: "5",
    tcp_keepalives_count: "3"
  ],
  socket_options: [keepalive: true]

config :arrow, ArrowWeb.AuthManager,
  issuer: "arrow",
  max_session_time: max_session_time,
  # 30 minutes
  idle_time: 30 * 60

# Configures the endpoint
config :arrow, ArrowWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ArrowWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Arrow.PubSub,
  live_view: [signing_salt: "35DDvOCJ"]

# Configures Oban, the job processing library
config :arrow, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, gtfs_import: 1],
  repo: Arrow.Repo

config :arrow,
  ecto_repos: [Arrow.Repo],
  aws_rds_mod: ExAws.RDS,
  run_migrations_at_startup?: false,
  fetch_adjustments?: true,
  adjustments_url: "https://mbta-gtfs-s3.s3.amazonaws.com/arrow/shuttles.json",
  # Run migrations synchronously before anything else. Must finish in <5 seconds
  migrate_synchronously?: true,
  redirect_http?: true,
  ueberauth_provider: :keycloak,
  required_roles: %{
    view_disruption: ["read-only", "admin"],
    create_disruption: ["admin"],
    update_disruption: ["admin"],
    delete_disruption: ["admin"],
    create_note: ["admin"],
    view_change_feed: ["admin"],
    publish_notice: ["admin"],
    db_dump: ["admin"]
  },
  time_zone: "America/New_York",
  ex_aws_requester: {Fake.ExAws, :admin_group_request},
  http_client: HTTPoison,
  shape_storage_enabled?: false,
  shape_storage_bucket: "mbta-arrow",
  shape_storage_prefix: "shape-uploads/",
  shape_storage_request_fn: {ExAws, :request},
  gtfs_archive_storage_enabled?: false,
  gtfs_archive_storage_bucket: "mbta-arrow",
  gtfs_archive_storage_prefix: "gtfs-archive-uploads/",
  gtfs_archive_storage_request_fn: {ExAws, :request},
  hastus_export_storage_enabled?: false,
  hastus_export_storage_bucket: "mbta-arrow",
  hastus_export_storage_prefix: "hastus-export-uploads/",
  hastus_export_storage_request_fn: {ExAws, :request},
  use_username_prefix?: false

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :esbuild,
  version: "0.17.11",
  default: [
    args: ~w(
      src/app.tsx
      --bundle
      --target=es2015
      --loader:.css=empty
      --outdir=../priv/static/assets
      --external:/fonts/*
      --external:/images/*
      --external:/css/*
      #{if(Mix.env() == :test, do: "--define:__REACT_DEVTOOLS_GLOBAL_HOOK__={'isDisabled':true}")}
    ),
    cd: Path.expand("../assets", __DIR__),
    env: %{
      "NODE_PATH" =>
        Enum.join(
          [Path.expand("../deps", __DIR__)],
          ":"
        )
    }
  ]

config :ex_aws, json_codec: Jason

config :ja_serializer,
  key_format: :underscored

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :phoenix, :format_encoders, "json-api": Jason

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ueberauth, Ueberauth,
  providers: [
    keycloak:
      {Ueberauth.Strategy.Oidcc,
       issuer: :keycloak_issuer,
       userinfo: true,
       uid_field: "email",
       scopes: ~w"openid email",
       authorization_params: %{max_age: "#{max_session_time}"},
       authorization_params_passthrough: ~w"prompt login_hint"}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
