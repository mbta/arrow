defmodule ArrowWeb.TryApiTokenAuth.Local do
  @moduledoc """
  Signs in an API client from a database token for read-only access.
  """

  alias Plug.Conn

  require Logger

  @spec sign_in(Conn.t(), Arrow.AuthToken.t()) :: Conn.t()
  def sign_in(%Conn{} = conn, %Arrow.AuthToken{} = auth_token) do
    Guardian.Plug.sign_in(conn, ArrowWeb.AuthManager, auth_token.username, %{roles: ["read-only"]}, ttl: {0, :second})
  end
end
