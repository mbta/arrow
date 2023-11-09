defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  plug Ueberauth

  @cognito_groups Application.compile_env!(:arrow, :cognito_groups)

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    username = auth.uid
    expiration = auth.credentials.expires_at
    credentials = conn.assigns.ueberauth_auth.credentials

    current_time = System.system_time(:second)

    groups = credentials.other[:groups] || []

    roles =
      Enum.flat_map(groups, fn group ->
        case @cognito_groups[group] do
          role when is_binary(role) -> [role]
          _ -> []
        end
      end)

    conn
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{roles: roles},
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
