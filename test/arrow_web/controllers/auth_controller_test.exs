defmodule ArrowWeb.Controllers.AuthControllerTest do
  use ArrowWeb.ConnCase

  alias ArrowWeb.Router.Helpers
  alias Ueberauth.Auth.Credentials

  describe "callback" do
    test "handles missing roles (keycloak)", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        provider: :keycloak,
        credentials: %Credentials{
          expires_at: current_time + 1_000,
          other: %{id_token: "id_token"}
        },
        extra: %{
          raw_info: %UeberauthOidcc.RawInfo{}
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
        |> get(Routes.auth_path(conn, :callback, "keycloak"))

      response = response(conn, 401)

      assert response =~ "unauthenticated"
    end
  end

  describe "logout" do
    test "logs user out and redirects to keycloak logout", %{conn: conn} do
      current_time = System.system_time(:second)

      auth = %Ueberauth.Auth{
        uid: "foo@mbta.com",
        provider: :keycloak,
        credentials: %Credentials{
          expires_at: current_time + 1_000,
          other: %{id_token: "id_token"}
        },
        extra: %{
          raw_info: %UeberauthOidcc.RawInfo{
            userinfo: %{
              "resource_access" => %{
                "fake_client" => %{"roles" => ["admin"]}
              }
            }
          }
        }
      }

      conn =
        conn
        |> assign(:ueberauth_auth, auth)
        |> get(Helpers.auth_path(conn, :callback, "keycloak"))

      assert Guardian.Plug.authenticated?(conn)
      conn = get(conn, Helpers.auth_path(conn, :logout, "keycloak"))

      refute Guardian.Plug.authenticated?(conn)
    end
  end

  test "redirects to auth_orig_path if present", %{conn: conn} do
    current_time = System.system_time(:second)
    original_path = "/some/original/path"

    auth = %Ueberauth.Auth{
      uid: "foo@mbta.com",
      provider: :keycloak,
      credentials: %Credentials{
        expires_at: current_time + 1_000,
        other: %{id_token: "id_token"}
      },
      extra: %{
        raw_info: %UeberauthOidcc.RawInfo{}
      }
    }

    conn =
      conn
      |> init_test_session(%{})
      |> put_session(:auth_orig_path, original_path)
      |> assign(:ueberauth_auth, auth)
      |> get(Routes.auth_path(conn, :callback, "keycloak"))

    response = html_response(conn, 302)
    assert response =~ original_path
  end

  test "redirects to root if auth_orig_path is not present", %{conn: conn} do
    current_time = System.system_time(:second)

    auth = %Ueberauth.Auth{
      uid: "foo@mbta.com",
      provider: :keycloak,
      credentials: %Credentials{
        expires_at: current_time + 1_000,
        other: %{id_token: "id_token"}
      },
      extra: %{
        raw_info: %UeberauthOidcc.RawInfo{}
      }
    }

    conn =
      conn
      |> init_test_session(%{})
      |> assign(:ueberauth_auth, auth)
      |> get(Routes.auth_path(conn, :callback, "keycloak"))

    response = html_response(conn, 302)
    assert response =~ "/"
  end
end
