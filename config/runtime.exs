import Config

is_test? = config_env() == :test

keycloak_issuer =
  case System.get_env() do
    %{"KEYCLOAK_ISSUER" => issuer} when issuer != "" ->
      issuer

    %{"KEYCLOAK_DISCOVERY_URI" => well_known} when well_known != "" ->
      String.replace_trailing(well_known, "/.well-known/openid-configuration", "")

    _ ->
      nil
  end

config :arrow, Arrow.OpenRouteServiceAPI,
  api_base_url: System.get_env("OPEN_ROUTE_SERVICE_API_URL"),
  api_key: System.get_env("OPEN_ROUTE_SERVICE_API_KEY"),
  client: Arrow.OpenRouteServiceAPI.Client

if is_binary(keycloak_issuer) and not is_test? do
  config :arrow,
    keycloak_client_uuid: System.fetch_env!("KEYCLOAK_CLIENT_UUID"),
    keycloak_api_base: System.fetch_env!("KEYCLOAK_API_BASE")

  keycloak_opts = [
    client_id: System.fetch_env!("KEYCLOAK_CLIENT_ID"),
    client_secret: System.fetch_env!("KEYCLOAK_CLIENT_SECRET")
  ]

  config :ueberauth_oidcc,
    issuers: [
      %{
        name: :keycloak_issuer,
        issuer: keycloak_issuer
      }
    ],
    providers: [
      keycloak: keycloak_opts
    ]
end

if config_env() == :prod do
  sentry_env = System.get_env("SENTRY_ENV")

  if not is_nil(sentry_env) do
    config :sentry,
      dsn: System.fetch_env!("SENTRY_DSN"),
      environment_name: sentry_env,
      enable_source_code_context: true,
      root_source_code_path: File.cwd!(),
      tags: %{
        env: sentry_env
      },
      traces_sample_rate: 1.0,
      traces_sampler: fn sampling_context ->
        if !sampling_context.parent_sampled &&
             sampling_context.transaction_context.op in [
               "arrow.repo.query:oban_jobs",
               "arrow.repo.query",
               "Elixir.Oban.Stager process",
               "arrow.repo.query:oban_peers"
             ] do
          false
        else
          1.0
        end
      end

    config :opentelemetry, span_processor: {Sentry.OpenTelemetry.SpanProcessor, []}
    config :opentelemetry, sampler: {Sentry.OpenTelemetry.Sampler, []}

    config :logger, Sentry.LoggerBackend,
      level: :warning,
      capture_log_messages: true
  end

  config :arrow, ArrowWeb.Endpoint,
    http: [:inet6, port: System.get_env("PORT", "4000")],
    url: [host: System.get_env("HOST"), port: 443, scheme: "https"],
    cache_static_manifest: "priv/static/cache_manifest.json",
    server: true,
    secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

  pool_size =
    case System.get_env("DATABASE_POOL_SIZE") do
      nil -> 10
      val -> String.to_integer(val)
    end

  port = System.get_env("DATABASE_PORT") |> String.to_integer()

  config :arrow, Arrow.Repo,
    username: System.get_env("DATABASE_USER"),
    database: System.get_env("DATABASE_NAME"),
    hostname: System.get_env("DATABASE_HOST"),
    port: port,
    pool_size: pool_size,
    # password set by `configure` callback below
    configure: {Arrow.Repo, :before_connect, []},
    queue_target: 30_000,
    queue_interval: 120_000

  config :arrow,
    shape_storage_prefix_env: System.get_env("S3_PREFIX"),
    gtfs_archive_storage_prefix_env: System.get_env("S3_PREFIX"),
    hastus_export_storage_prefix_env: System.get_env("S3_PREFIX")
else
  # config :opentelemetry, traces_exporter: :none

  # config :sentry,
  #   dsn: "https://9a8ec21a31c1404a8fab7353e585caf7@o89189.ingest.sentry.io/4504753753751552",
  #   environment_name: "whoops-local",
  #   enable_source_code_context: true,
  #   root_source_code_path: File.cwd!(),
  #   tags: %{
  #     env: "whoops-local"
  #   },
  #   traces_sample_rate: 1.0,
  #   traces_sampler: fn sampling_context ->
  #     if !sampling_context.parent_sampled &&
  #          sampling_context.transaction_context.op in [
  #            "arrow.repo.query:oban_jobs",
  #            "arrow.repo.query",
  #            "Elixir.Oban.Stager process",
  #            "arrow.repo.query:oban_peers"
  #          ] do
  #       false
  #     else
  #       1.0
  #     end
  #   end

  # config :opentelemetry, span_processor: {Sentry.OpenTelemetry.SpanProcessor, []}
  # config :opentelemetry, sampler: {Sentry.OpenTelemetry.Sampler, []}
end

sync_enabled = System.get_env("ARROW_SYNC_ENABLED") == "true"

if sync_enabled && config_env() != :test do
  config :arrow,
    sync_enabled: true,
    sync_domain: System.fetch_env!("ARROW_DOMAIN"),
    sync_api_key: System.fetch_env!("ARROW_API_KEY")

  config :arrow, Oban,
    plugins: [
      {Oban.Plugins.Cron,
       crontab: [
         # Sync stops and shapes from prod to dev hourly
         {"0 * * * *", Arrow.SyncWorker}
       ]}
    ]
else
  config :arrow,
    sync_enabled: false
end
