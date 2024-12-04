import Config

# Configure your database
config :arrow, Arrow.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "postgres",
  database: "arrow_dev",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :arrow, ArrowWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  secret_key_base: "local_secret_key_base_at_least_64_bytes_________________________________",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    node:
      ~w(assets/node_modules/.bin/tsc --project assets --noEmit --watch --preserveWatchOutput),
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :arrow, ArrowWeb.AuthManager, secret_key: "test key"

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :arrow, ArrowWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/arrow_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :ueberauth, Ueberauth,
  providers: [
    cognito: {Arrow.Ueberauth.Strategy.Fake, []}
  ]

config :arrow, :redirect_http?, false

# Enable dev routes for dashboard and mailbox
config :arrow, dev_routes: true

# Set prefix env for s3 uploads
config :arrow,
  ueberauth_provider: :cognito,
  api_login_module: ArrowWeb.TryApiTokenAuth.Cognito,
  shape_storage_enabled?: true,
  shape_storage_prefix_env: "dev/local/",
  gtfs_archive_storage_enabled?: true,
  gtfs_archive_storage_prefix_env: "dev/local/"
  

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true

# Enable helpful, but potentially expensive runtime checks
# enable_expensive_runtime_checks: true
