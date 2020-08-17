use Mix.Config

# Configure your database
config :arrow, Arrow.Repo,
  username: System.get_env("DATABASE_POSTGRESQL_USERNAME") || "postgres",
  password: System.get_env("DATABASE_POSTGRESQL_PASSWORD") || "postgres",
  database: "arrow_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :arrow, ArrowWeb.Endpoint,
  http: [port: 4002],
  secret_key_base: "local_secret_key_base_at_least_64_bytes_________________________________",
  server: false

config :arrow, ArrowWeb.AuthManager, secret_key: "test key"

config :ueberauth, Ueberauth,
  providers: [
    cognito: {Arrow.Ueberauth.Strategy.Fake, []}
  ]

config :arrow,
  fetch_adjustments?: false,
  http_client: Arrow.HTTPMock

# Print only warnings and errors during test
config :logger, level: :warn

config :arrow, env: :test
