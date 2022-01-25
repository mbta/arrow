defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  plug Ueberauth

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    username = auth.info.email
    expiration = auth.credentials.expires_at
    credentials = conn.assigns.ueberauth_auth.credentials

    current_time = System.system_time(:second)

    conn
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{groups: credentials.other[:groups]},
      ttl: {expiration - current_time, :seconds}
    )
    |> put_session(:arrow_username, username)
    |> redirect(to: Routes.disruption_path(conn, :index))
  end

  def callback(
        %{assigns: %{ueberauth_failure: %Ueberauth.Failure{}}} = conn,
        _params
      ) do
    send_resp(conn, 401, "unauthenticated")
  end
end
