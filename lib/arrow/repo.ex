defmodule Arrow.Repo do
  use Ecto.Repo,
    otp_app: :arrow,
    adapter: Ecto.Adapters.Postgres

  @default_pool_size 10

  def init(_context, config) do
    pool_size_env = System.get_env("DATABASE_POOL_SIZE")
    pool_size_env = if pool_size_env, do: String.to_integer(pool_size_env)
    pool_size = pool_size_env || Keyword.get(config, :pool_size) || @default_pool_size
    config = Keyword.put(config, :pool_size, pool_size)

    config =
      if Keyword.take(config, [:database, :username, :password, :hostname]) == [] do
        username = System.get_env("DATABASE_USER")
        database = System.get_env("DATABASE_NAME")
        hostname = System.get_env("DATABASE_HOST")
        port = "DATABASE_PORT" |> System.get_env() |> String.to_integer()

        if !username, do: raise("missing DATABASE_USER environment variable")
        if !database, do: raise("missing DATABASE_NAME environment variable")
        if !hostname, do: raise("missing DATABASE_HOST environment variable")

        mod = Application.get_env(:arrow, :aws_rds_mod)
        token = apply(mod, :generate_db_auth_token, [hostname, username, port, %{}])

        Keyword.merge(config,
          database: database,
          username: username,
          hostname: hostname,
          password: token,
          port: port
        )
      else
        config
      end

    {:ok, config}
  end
end
