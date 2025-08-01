defmodule ArrowWeb.TryApiTokenAuth.KeycloakTest do
  use ArrowWeb.ConnCase

  import ExUnit.CaptureLog
  import Mox
  import Test.Support.Helpers

  alias Arrow.HTTPMock
  alias ArrowWeb.TryApiTokenAuth.Keycloak

  setup :verify_on_exit!

  setup do
    reassign_env(:ueberauth,
      Ueberauth: [
        providers: [
          keycloak: {Ueberauth.Strategy.Oidcc, []}
        ]
      ]
    )
  end

  describe "sign_in/2" do
    test "signs in an admin", %{conn: conn} do
      auth_token = auth_token_for("arrow-admin@example.com")

      expect(HTTPMock, :get, fn url, headers, opts ->
        assert url == "https://keycloak.example/auth/realm/users"
        assert {_, "Bearer fake_access_token"} = List.keyfind(headers, "authorization", 0)

        assert %{
                 email: "arrow-admin@example.com"
               } = opts[:params]

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!([%{id: "admin_user_id"}])
         }}
      end)

      expect(HTTPMock, :get, fn _url, _headers, _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!([%{name: "read-only"}, %{name: "admin"}])
         }}
      end)

      conn = Keycloak.sign_in(conn, auth_token)

      assert Guardian.Plug.authenticated?(conn)
      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == "arrow-admin@example.com"
      assert claims["typ"] == "access"
      assert claims["roles"] == ["read-only", "admin"]
      assert Guardian.Plug.current_resource(conn) == "arrow-admin@example.com"
    end

    test "signs in a read-only user", %{conn: conn} do
      auth_token = auth_token_for("arrow-read-only@example.com")

      expect(HTTPMock, :get, fn _url, _headers, opts ->
        assert %{
                 email: "arrow-read-only@example.com"
               } = opts[:params]

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!([%{id: "read_only_user_id"}])
         }}
      end)

      expect(HTTPMock, :get, fn url, _headers, _opts ->
        assert url ==
                 "https://keycloak.example/auth/realm/users/read_only_user_id/role-mappings/clients/UUID/composite"

        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!([%{name: "read-only"}])
         }}
      end)

      conn = Keycloak.sign_in(conn, auth_token)

      assert Guardian.Plug.authenticated?(conn)
      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == "arrow-read-only@example.com"
      assert claims["typ"] == "access"
      assert claims["roles"] == ["read-only"]
      assert Guardian.Plug.current_resource(conn) == "arrow-read-only@example.com"
    end

    test "does not sign in a user who does not exist in Keycloak", %{conn: conn} do
      auth_token = auth_token_for("arrow-missing@example.com")

      expect(HTTPMock, :get, fn _url, _headers, _opts ->
        {:ok,
         %HTTPoison.Response{
           status_code: 200,
           body: Jason.encode!([])
         }}
      end)

      {conn, log} = with_log(fn -> Keycloak.sign_in(conn, auth_token) end)

      refute Guardian.Plug.authenticated?(conn)

      assert log =~ "{:error, :missing_user}"
    end
  end

  defp auth_token_for(email) do
    token = Arrow.AuthToken.get_or_create_token_for_user(email)
    Arrow.Repo.get_by(Arrow.AuthToken, token: token)
  end
end
