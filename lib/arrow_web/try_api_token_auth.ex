defmodule ArrowWeb.TryApiTokenAuth do
  @moduledoc """
  Plug for authentication via API token, used by e.g. gtfs_creator
  """

  import Plug.Conn
  require Logger

  def init(options), do: options

  def call(conn, _opts) do
    api_key_values = get_req_header(conn, "x-api-key")

    with [token | _] <- api_key_values,
         token = String.downcase(token),
         auth_token = %Arrow.AuthToken{} <-
           Arrow.Repo.get_by(Arrow.AuthToken, token: token),
         api_login_module = Application.get_env(:arrow, :api_login_module),
         conn = api_login_module.sign_in(conn, auth_token),
         true <- Guardian.Plug.authenticated?(conn) do
      conn
    else
      [] ->
        # no API key present, pass on through
        conn

      reason ->
        Logger.info(
          "unable to login in API client api_key=#{inspect(api_key_values)} reason=#{inspect(reason)}"
        )

        conn |> send_resp(401, "unauthenticated") |> halt()
    end
  end
end
