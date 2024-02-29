defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  require Logger

  plug(Ueberauth)

  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    logout_url = get_session(conn, :logout_url)
    conn = configure_session(conn, drop: true)

    if logout_url do
      redirect(conn, external: logout_url)
    else
      redirect(conn, to: "/")
    end
  end

  @cognito_groups Application.compile_env!(:arrow, :cognito_groups)

  @spec callback(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def callback(%{assigns: %{ueberauth_auth: %{provider: :cognito} = auth}} = conn, _params) do
    username = auth.uid
    expiration = auth.credentials.expires_at
    current_time = System.system_time(:second)

    groups = Map.get(auth.credentials.other, :groups, [])

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
      %{
        # all cognito users have read-only access
        roles: roles ++ ["read-only"]
      },
      ttl: {expiration - current_time, :seconds}
    )
    |> redirect(to: Routes.disruption_path(conn, :index))
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: :keycloak} = auth}} = conn, _params) do
    username = auth.uid
    expiration = auth.credentials.expires_at
    current_time = System.system_time(:second)

    roles = auth.extra.raw_info.userinfo["roles"] || []

    logout_url =
      case UeberauthOidcc.initiate_logout_url(auth, %{
             post_logout_redirect_uri: "https://www.mbta.com/"
           }) do
        {:ok, url} ->
          url

        _ ->
          nil
      end

    conn
    |> put_session(:logout_url, logout_url)
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{
        roles: roles
      },
      ttl: {expiration - current_time, :seconds}
    )
    |> redirect(to: Routes.disruption_path(conn, :index))
  end

  def callback(
        %{assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: errors}}} = conn,
        _params
      ) do
    Logger.warning("failed to authenticate errors=#{inspect(errors)}")

    send_resp(conn, 401, "unauthenticated")
  end
end
