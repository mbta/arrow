defmodule Arrow.Repo do
  use Ecto.Repo,
    otp_app: :arrow,
    adapter: Ecto.Adapters.Postgres
end
