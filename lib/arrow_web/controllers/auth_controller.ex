defmodule ArrowWeb.AuthController do
  use ArrowWeb, :controller
  require Logger

  plug(Ueberauth)

  @spec logout(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def logout(conn, _params) do
    redirect_opts =
      if logout_url = get_session(conn, :logout_url) do
        [external: logout_url]
      else
        [to: "/"]
      end

    conn
    |> Guardian.Plug.sign_out(Arrow.AuthManager)
    |> configure_session(drop: true)
    |> redirect(redirect_opts)
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: :keycloak} = auth}} = conn, _params) do
    username = auth.uid

    auth_time =
      Map.get(
        auth.extra.raw_info.claims,
        "auth_time",
        auth.extra.raw_info.claims["iat"]
      )

    roles = auth.extra.raw_info.userinfo["roles"] || []

    redirect_path = get_session(conn, :auth_orig_path, Routes.disruption_path(conn, :index))

    logout_url =
      case UeberauthOidcc.initiate_logout_url(auth, %{
             post_logout_redirect_uri: "https://www.mbta.com/"
           }) do
        {:ok, url} ->
          url

        _ ->
          nil
      end

    Logger.info("roles_for_user #{IO.inspect(roles)}")

    conn
    |> configure_session(drop: true)
    |> put_session(:logout_url, logout_url)
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      username,
      %{
        auth_time: auth_time,
        roles: roles
      },
      ttl: {1, :minute}
    )
    |> redirect(to: redirect_path)
  end

  def callback(
        %{assigns: %{ueberauth_failure: %Ueberauth.Failure{errors: errors}}} = conn,
        _params
      ) do
    Logger.warning("failed to authenticate errors=#{inspect(errors)}")

    send_resp(conn, 401, "unauthenticated")
  end
end
