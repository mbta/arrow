defmodule ArrowWeb.TryApiTokenAuthTest do
  use ArrowWeb.ConnCase

  import Mox

  alias Arrow.HTTPMock

  describe "init/1" do
    test "passes options through unchanged" do
      assert ArrowWeb.TryApiTokenAuth.init([]) == []
    end
  end

  describe "call/2" do
    test "does nothing if x-api-key header not present", %{conn: conn} do
      old_conn = conn
      conn = ArrowWeb.TryApiTokenAuth.call(conn, [])

      assert conn == old_conn
    end

    test "sends 401 unauthenticated if incorrect API key given", %{conn: conn} do
      response =
        conn
        |> put_req_header("x-api-key", "made_up_api_key")
        |> ArrowWeb.TryApiTokenAuth.call([])
        |> response(401)

      assert response =~ "unauthenticated"
    end

    test "signs user in if correct API key given", %{conn: conn} do
      auth_token = auth_token_for("foo@mbta.com")

      expect(HTTPMock, :get, fn url, headers, opts ->
        assert url == "https://keycloak.example/auth/realm/users"
        assert {_, "Bearer fake_access_token"} = List.keyfind(headers, "authorization", 0)

        assert %{
                 email: "foo@mbta.com"
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

      conn =
        conn
        |> put_req_header("x-api-key", auth_token.token)
        |> ArrowWeb.TryApiTokenAuth.call([])

      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == "foo@mbta.com"
      assert claims["typ"] == "access"
      assert claims["roles"] == ["read-only", "admin"]
      assert Guardian.Plug.current_resource(conn) == "foo@mbta.com"
    end

    test "handles API token with local database token from gtfs_creator user", %{conn: conn} do
      token = Arrow.AuthToken.get_or_create_token_for_user("gtfs_creator_ci@mbta.com")

      conn =
        conn
        |> put_req_header("x-api-key", token)
        |> ArrowWeb.TryApiTokenAuth.call([])

      claims = Guardian.Plug.current_claims(conn)

      assert claims["roles"] == ["read-only"]
      assert Guardian.Plug.current_resource(conn) == "gtfs_creator_ci@mbta.com"
    end
  end

  defp auth_token_for(email) do
    token = Arrow.AuthToken.get_or_create_token_for_user(email)
    Arrow.Repo.get_by(Arrow.AuthToken, token: token)
  end
end
