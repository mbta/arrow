defmodule ArrowWeb.TryApiTokenAuthTest do
  use ArrowWeb.ConnCase
  use Plug.Test

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
      token = Arrow.AuthToken.get_or_create_token_for_user("foo@mbta.com")

      conn =
        conn
        |> init_test_session([])
        |> put_req_header("x-api-key", token)
        |> ArrowWeb.TryApiTokenAuth.call([])

      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == "foo@mbta.com"
      assert claims["typ"] == "access"
      assert Plug.Conn.get_session(conn, :arrow_username) == "foo@mbta.com"
    end
  end
end
