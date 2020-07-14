defmodule ArrowWeb.TryApiTokenAuth do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    api_key_values = get_req_header(conn, "x-api-key")

    if api_key_values == [] do
      conn
    else
      [token | _] = api_key_values
      token = String.downcase(token)

      auth_token = Arrow.Repo.get_by(Arrow.AuthToken, token: token)

      if is_nil(auth_token) do
        send_resp(conn, 401, "unauthenticated")
      else
        conn
        |> Guardian.Plug.sign_in(
          ArrowWeb.AuthManager,
          auth_token.username,
          %{groups: ["arrow-admin"]}
        )
        |> Plug.Conn.put_session(:arrow_username, auth_token.username)
      end
    end
  end
end
