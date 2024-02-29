defmodule ArrowWeb.Controllers.AuthControllerTest do
  use ArrowWeb.ConnCase

  describe "callback" do
    test "redirects on success (cognito)", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        provider: :cognito,
        credentials: %Ueberauth.Auth.Credentials{
          expires_at: current_time + 1_000,
          other: %{groups: ["arrow-admin"]}
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(Routes.auth_path(conn, :callback, "cognito"))

      response = html_response(conn, 302)

      assert response =~ Routes.disruption_path(conn, :index)

      assert Enum.sort(Guardian.Plug.current_claims(conn)["roles"]) == ["admin", "read-only"]
      assert Guardian.Plug.current_resource(conn) == "foo@mbta.com"
    end

    test "redirects on success (keycloak)", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        provider: :keycloak,
        credentials: %Ueberauth.Auth.Credentials{
          expires_at: current_time + 1_000,
          other: %{id_token: "id_token"}
        },
        extra: %{
          raw_info: %{
            claims: %{"session_state" => "session state"},
            userinfo: %{
              "roles" => ["admin"]
            }
          }
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(Routes.auth_path(conn, :callback, "keycloak"))

      response = html_response(conn, 302)

      assert response =~ Routes.disruption_path(conn, :index)
      assert get_session(conn, :session_state) == {"session state", ["admin"]}
      assert Guardian.Plug.current_claims(conn)["roles"] == ["admin"]
      assert Guardian.Plug.current_resource(conn) == "foo@mbta.com"
    end

    test "handles missing roles (keycloak)", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        provider: :keycloak,
        credentials: %Ueberauth.Auth.Credentials{
          expires_at: current_time + 1_000,
          other: %{id_token: "id_token"}
        },
        extra: %{
          raw_info: %{
            claims: %{},
            userinfo: %{}
          }
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(Routes.auth_path(conn, :callback, "keycloak"))

      response = html_response(conn, 302)

      assert response =~ Routes.disruption_path(conn, :index)
      assert Guardian.Plug.current_claims(conn)["roles"] == []
      assert Guardian.Plug.current_resource(conn) == "foo@mbta.com"
    end

    @tag :capture_log
    test "handles generic failure", %{conn: conn} do
      conn =
        conn
        |> assign(:ueberauth_failure, %Ueberauth.Failure{})
        |> get(Routes.auth_path(conn, :callback, "cognito"))

      response = response(conn, 401)

      assert response =~ "unauthenticated"
    end
  end

  describe "request" do
    test "redirects to auth callback", %{conn: conn} do
      conn = get(conn, Routes.auth_path(conn, :request, "cognito"))

      response = response(conn, 302)

      assert response =~ Routes.auth_path(conn, :callback, "cognito")
    end
  end
end
