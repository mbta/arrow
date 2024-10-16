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

if is_binary(keycloak_issuer) and not is_test? do
  config :arrow,
    ueberauth_provider: :keycloak,
    api_login_module: ArrowWeb.TryApiTokenAuth.Keycloak,
    keycloak_client_uuid: System.fetch_env!("KEYCLOAK_CLIENT_UUID"),
    keycloak_api_base: System.fetch_env!("KEYCLOAK_API_BASE")

  keycloak_opts = [
    client_id: System.fetch_env!("KEYCLOAK_CLIENT_ID"),
    client_secret: System.fetch_env!("KEYCLOAK_CLIENT_SECRET")
  ]

  keycloak_opts =
    if keycloak_idp = System.get_env("KEYCLOAK_IDP_HINT") do
      Keyword.put(keycloak_opts, :authorization_params, %{kc_idp_hint: keycloak_idp})
    else
      keycloak_opts
    end

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
      included_environments: [sentry_env]

    config :logger, Sentry.LoggerBackend,
      level: :warn,
      capture_log_messages: true
  end

  config :arrow, ArrowWeb.Endpoint, secret_key_base: System.fetch_env!("SECRET_KEY_BASE")

  config :ueberauth, Ueberauth,
    providers: [
      cognito:
        {Ueberauth.Strategy.Cognito, [client_secret: System.fetch_env!("COGNITO_CLIENT_SECRET")]}
    ]

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
    queue_interval: 120_000,
    log: :info,
    timeout: 15_000

  config :arrow,
    shape_storage_prefix_env: System.get_env("S3_PREFIX"),
    gtfs_archive_storage_prefix_env: System.get_env("S3_PREFIX")
end
