import Config

config :arrow,
  shape_storage_enabled?: false,
  shape_storage_request_fn: {Arrow.Mock.ExAws.Request, :request},
  gtfs_archive_storage_enabled?: false,
  gtfs_archive_storage_request_fn: {Arrow.Mock.ExAws.Request, :request},
  hastus_export_storage_enabled?: false,
  hastus_export_storage_request_fn: {Arrow.Mock.ExAws.Request, :request}

# Configure your database
config :arrow, Arrow.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: "arrow_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :arrow, ArrowWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "local_secret_key_base_at_least_64_bytes_________________________________",
  server: true

config :arrow, ArrowWeb.AuthManager, secret_key: "test key"

# Prevent Oban from running jobs and plugins during test runs
config :arrow, Oban, testing: :inline

config :ueberauth, Ueberauth,
  providers: [
    keycloak: {Arrow.Ueberauth.Strategy.Fake, [groups: ["admin"]]}
  ]

# Configure Keycloak
config :arrow,
  keycloak_api_base: "https://keycloak.example/auth/realm/",
  keycloak_client_uuid: "UUID"

config :ueberauth_oidcc,
  providers: [
    keycloak: [
      issuer: :fake_issuer,
      client_id: "fake_client",
      client_secret: "fake_client_secret",
      module: Arrow.FakeOidcc
    ]
  ]

config :arrow,
  fetch_adjustments?: false,
  http_client: Arrow.HTTPMock

# Print only warnings and errors during test
config :logger, level: :warning

config :arrow, env: :test

config :wallaby,
  driver: Wallaby.Chrome,
  otp_app: :arrow,
  screenshot_dir: "test/integration/screenshots",
  screenshot_on_failure: true,
  max_wait_time: 10000

config :ex_aws,
  access_key_id: "test_access_key_id",
  secret_access_key: "test_secret_access_key",
  region: "us-east-1"
