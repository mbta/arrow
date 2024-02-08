defmodule ArrowWeb.TryApiTokenAuth.LocalTest do
  use ArrowWeb.ConnCase
  import ExUnit.CaptureLog

  alias ArrowWeb.TryApiTokenAuth.Local

  describe "sign_in/2" do
    test "signs in a read-only token user", %{conn: conn} do
      local_token_email = "gtfs_creator_ci@mbta.com"
      auth_token = auth_token_for(local_token_email)

      conn = Local.sign_in(conn, auth_token)

      assert Guardian.Plug.authenticated?(conn)
      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == local_token_email
      assert claims["typ"] == "access"
      assert claims["roles"] == ["read-only"]
      assert Guardian.Plug.current_resource(conn) == local_token_email
    end

    test "does not sign in a token user who does not exist", %{conn: conn} do
      auth_token = auth_token_for("arrow-missing@mbta.com")

      assert_raise FunctionClauseError, fn ->
        Local.sign_in(conn, auth_token)
      end

      refute Guardian.Plug.authenticated?(conn)
    end

    test "does not sign in a token user who does not have an @mbta.com email", %{conn: conn} do
      unknown_domain = "arrow-missing@unknown.com"
      Arrow.AuthToken.get_or_create_token_for_user(unknown_domain)
      auth_token = auth_token_for(unknown_domain)

      {conn, log} = with_log(fn -> Local.sign_in(conn, auth_token) end)

      refute Guardian.Plug.authenticated?(conn)

      assert log =~ "refusing to login"
    end
  end

  defp auth_token_for(username) do
    Arrow.Repo.get_by(Arrow.AuthToken, username: username)
  end
end
