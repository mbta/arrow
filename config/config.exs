# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :arrow,
  ecto_repos: [Arrow.Repo],
  aws_rds_mod: ExAws.RDS,
  run_migrations_at_startup?: false,
  fetch_adjustments?: true,
  adjustments_url: "https://mbta-gtfs-s3.s3.amazonaws.com/arrow/shuttles.json",
  # Run migrations synchronously before anything else. Must finish in <5 seconds
  migrate_synchronously?: true,
  redirect_http?: true,
  cognito_groups: %{
    "arrow-admin" => :admin
  },
  required_groups: %{
    create_disruption: [:admin],
    update_disruption: [:admin],
    delete_disruption: [:admin],
    create_note: [:admin],
    use_api: [:admin],
    view_change_feed: [:admin]
  },
  time_zone: "America/New_York",
  ex_aws_requester: {Fake.ExAws, :admin_group_request},
  http_client: HTTPoison

# Configures the endpoint
config :arrow, ArrowWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ArrowWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Arrow.PubSub

config :esbuild,
  version: "0.12.18",
  default: [
    args: ~w(
      src/app.tsx
      --bundle
      --target=es2015
      --loader:.png=file
      --loader:.woff=file
      --outdir=../priv/static/assets
      #{if(Mix.env() == :test, do: "--define:__REACT_DEVTOOLS_GLOBAL_HOOK__={'isDisabled':true}")}
    ),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :arrow, ArrowWeb.AuthManager, issuer: "arrow"

config :ueberauth, Ueberauth.Strategy.Cognito,
  auth_domain: {System, :get_env, ["COGNITO_DOMAIN"]},
  client_id: {System, :get_env, ["COGNITO_CLIENT_ID"]},
  client_secret: {System, :get_env, ["COGNITO_CLIENT_SECRET"]},
  user_pool_id: {System, :get_env, ["COGNITO_USER_POOL_ID"]},
  aws_region: {System, :get_env, ["COGNITO_AWS_REGION"]}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, "json-api": Jason

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :ex_aws, json_codec: Jason

config :ja_serializer,
  key_format: :underscored

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
