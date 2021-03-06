defmodule ArrowWeb.Controllers.AuthControllerTest do
  use ArrowWeb.ConnCase

  describe "callback" do
    test "redirects on success and saves refresh token", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        credentials: %Ueberauth.Auth.Credentials{
          expires_at: current_time + 1_000,
          other: %{groups: ["test1"]}
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(ArrowWeb.Router.Helpers.auth_path(conn, :callback, "cognito"))

      response = html_response(conn, 302)

      assert response =~ ArrowWeb.Router.Helpers.page_path(conn, :index)
      assert Guardian.Plug.current_claims(conn)["groups"] == ["test1"]
      assert Plug.Conn.get_session(conn, :arrow_username) == "foo@mbta.com"
    end

    test "handles generic failure", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_failure, %Ueberauth.Failure{})
        |> get(ArrowWeb.Router.Helpers.auth_path(conn, :callback, "cognito"))

      response = response(conn, 401)

      assert response =~ "unauthenticated"
    end
  end

  describe "request" do
    test "redirects to auth callback", %{conn: conn} do
      conn = get(conn, ArrowWeb.Router.Helpers.auth_path(conn, :request, "cognito"))

      response = response(conn, 302)

      assert response =~ ArrowWeb.Router.Helpers.auth_path(conn, :callback, "cognito")
    end
  end
end
