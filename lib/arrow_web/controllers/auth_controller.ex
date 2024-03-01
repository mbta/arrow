defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  require Logger

  plug(Ueberauth)
  plug(:put_layout, false)

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

  def silent_sso_callback(conn, _params) do
    provider_name = :keycloak_prompt_none
    provider_config = Application.get_env(:ueberauth, Ueberauth)[:providers][provider_name]
    conn = Ueberauth.run_callback(conn, provider_name, provider_config)
    session_state = get_session(conn, :session_state)
    seen_success? = get_session(conn, :prompt_none_success?, false)

    conn =
      case conn.assigns do
        %{ueberauth_auth: _} ->
          conn
          |> put_session(:prompt_none_success?, true)
          |> keycloak_signin()

        %{ueberauth_failure: %Ueberauth.Failure{errors: errors}} when seen_success? ->
          Logger.info("user logged out errors=#{inspect(errors)}")

          conn
          |> put_session(:session_state, nil)
          |> Guardian.Plug.sign_out(ArrowWeb.AuthManager)

        %{} ->
          # if we haven't seen a successful silent login, assume that the
          # cookies are being blocked. don't log the user out, but also don't
          # extend the session.
          Logger.info("not changing state")
          conn
      end

    # ensure that being logged out is always treated as a change
    new_session_state = get_session(conn, :session_state, :new)

    conn =
      if session_state == new_session_state or not seen_success? do
        send_resp(conn, :ok, "")
      else
        send_resp(conn, :unauthorized, "")
      end

    halt(conn)
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

  def callback(%{assigns: %{ueberauth_auth: %{provider: :keycloak}}} = conn, _params) do
    conn
    |> keycloak_signin()
    |> redirect(to: Routes.disruption_path(conn, :index))
  end

  def callback(
        %{assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: errors}}} = conn,
        _params
      ) do
    Logger.warning("failed to authenticate errors=#{inspect(errors)}")

    send_resp(conn, 401, "unauthenticated")
  end

  defp keycloak_signin(conn) do
    auth = conn.assigns.ueberauth_auth
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
    |> put_session(:session_state, {auth.extra.raw_info.claims["session_state"], roles})
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{
        roles: roles
      },
      ttl: {expiration - current_time, :seconds}
    )
  end
end
