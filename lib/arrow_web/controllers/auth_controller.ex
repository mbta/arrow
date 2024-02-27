defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  require Logger

  plug :put_layout, false
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

  def session_state(conn, _params) do
    {client_id, session_state} = get_session(conn, :session_state)
    check_session_iframe = get_session(conn, :check_session_iframe)
    target_origin = check_session_iframe
    |> URI.parse()
    |> then(fn uri -> "#{uri.scheme}://#{uri.host}" end)

    render(conn, :session_state, client_id: client_id, session_state: session_state, target_origin: target_origin)
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
    IO.inspect(auth)
    username = auth.uid
    expiration = auth.credentials.expires_at
    current_time = System.system_time(:second)

    roles = auth.extra.raw_info.userinfo["roles"] || []

    provider_configuration = Oidcc.ProviderConfiguration.Worker.get_provider_configuration(:keycloak_issuer)
    check_session_iframe  = provider_configuration.extra_fields["check_session_iframe"]
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
    |> put_session(:check_session_iframe, check_session_iframe)
    |> put_session(:session_state, {auth.extra.raw_info.claims["azp"], auth.extra.raw_info.claims["session_state"]})
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{
        roles: roles,
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
