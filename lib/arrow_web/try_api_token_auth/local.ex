defmodule ArrowWeb.TryApiTokenAuth.Local do
  @moduledoc """
  Signs in an API client from a database token for read-only access.
  """

  alias Plug.Conn
  require Logger

  @spec sign_in(Conn.t(), Arrow.AuthToken.t()) :: Conn.t()
  def sign_in(%Conn{} = conn, %Arrow.AuthToken{} = auth_token) do
    if String.ends_with?(
         auth_token.username,
         Application.get_env(:arrow, :local_token_allowed_domain)
       ) do
      conn
      |> Guardian.Plug.sign_in(
        ArrowWeb.AuthManager,
        auth_token.username,
        %{roles: ["read-only"]},
        ttl: {0, :second}
      )
    else
      Logger.warn(
        "refusing to login in API client username=#{inspect(auth_token.username)} reason=unexpected username"
      )

      conn
    end
  end
end
