import Config

alias Arrow.Mock.ExAws.Request

# Configure your database
config :arrow, Arrow.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: "arrow_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :arrow, ArrowWeb.AuthManager, secret_key: "test key"

config :arrow, ArrowWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "local_secret_key_base_at_least_64_bytes_________________________________",
  server: true

# Prevent Oban from running jobs and plugins during test runs
config :arrow, Oban, testing: :inline
config :arrow, env: :test

config :arrow,
  fetch_adjustments?: false,
  http_client: Arrow.HTTPMock

# Configure Keycloak
config :arrow,
  keycloak_api_base: "https://keycloak.example/auth/realm/",
  keycloak_client_uuid: "UUID"

config :arrow,
  shape_storage_enabled?: false,
  shape_storage_request_fn: {Request, :request},
  gtfs_archive_storage_enabled?: false,
  gtfs_archive_storage_request_fn: {Request, :request},
  hastus_export_storage_enabled?: false,
  hastus_export_storage_request_fn: {Request, :request}

config :arrow,
  sync_enabled: false,
  sync_api_key: "test-key",
  sync_domain: "https://test.example.com"

config :ex_aws,
  access_key_id: "test_access_key_id",
  secret_access_key: "test_secret_access_key",
  region: "us-east-1"

# Print only warnings and errors during test
config :logger, level: :warning

config :ueberauth, Ueberauth,
  providers: [
    keycloak: {Arrow.Ueberauth.Strategy.Fake, [groups: ["admin"]]}
  ]

config :ueberauth_oidcc,
  providers: [
    keycloak: [
      issuer: :fake_issuer,
      client_id: "fake_client",
      client_secret: "fake_client_secret",
      module: Arrow.FakeOidcc
    ]
  ]

config :wallaby,
  driver: Wallaby.Chrome,
  otp_app: :arrow,
  screenshot_dir: "test/integration/screenshots",
  screenshot_on_failure: true,
  max_wait_time: 10_000
