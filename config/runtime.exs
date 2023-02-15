import Config

if config_env() == :prod do
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
    configure: {Arrow.Repo, :before_connect, []}
end
