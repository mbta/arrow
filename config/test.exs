import Config

# Configure your database
config :arrow, Arrow.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: "arrow_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :arrow,
  shape_storage_enabled?: false

config :arrow, ArrowWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "local_secret_key_base_at_least_64_bytes_________________________________",
  server: true

config :arrow, ArrowWeb.AuthManager, secret_key: "test key"

config :ueberauth, Ueberauth,
  providers: [
    cognito: {Arrow.Ueberauth.Strategy.Fake, []},
    keycloak: {Ueberauth.Strategy.Oidcc, []}
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
  screenshot_on_failure: true
