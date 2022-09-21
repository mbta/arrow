import Config

if config_env() == :prod do
  config :arrow, ArrowWeb.Endpoint, secret_key_base: System.fetch_env!("SECRET_KEY_BASE")
end

config :ueberauth, Ueberauth,
  providers: [
    cognito:
      {Ueberauth.Strategy.Cognito, [client_secret: System.get_env("COGNITO_CLIENT_SECRET")]}
  ]
