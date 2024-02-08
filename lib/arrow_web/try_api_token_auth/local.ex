defmodule ArrowWeb.TryApiTokenAuth.Local do
  @moduledoc """
  Signs in an API client from a local database token for read-only access.
  """

  require Logger

  def sign_in(conn, auth_token) do
    if String.ends_with?(auth_token.username, "@mbta.com") do
      conn
      |> Guardian.Plug.sign_in(
        ArrowWeb.AuthManager,
        auth_token.username,
        %{roles: ["read-only"]},
        ttl: {0, :second}
      )
    else
      Logger.info(
        "refusing to login in API client username=#{inspect(auth_token.username)} reason=unexpected username"
      )

      conn
    end
  end
end
