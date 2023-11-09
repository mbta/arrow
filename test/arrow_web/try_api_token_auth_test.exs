defmodule ArrowWeb.TryApiTokenAuthTest do
  use ArrowWeb.ConnCase
  import ExUnit.CaptureLog
  import Test.Support.Helpers

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
      old_ueberauth_config = Application.get_env(:ueberauth, Ueberauth.Strategy.Cognito)

      on_exit(fn ->
        Application.put_env(:ueberauth, Ueberauth.Strategy.Cognito, old_ueberauth_config)
      end)

      Application.put_env(
        :ueberauth,
        Ueberauth.Strategy.Cognito,
        Keyword.put(old_ueberauth_config, :user_pool_id, "dummy_pool")
      )

      token = Arrow.AuthToken.get_or_create_token_for_user("foo@mbta.com")

      conn =
        conn
        |> put_req_header("x-api-key", token)
        |> ArrowWeb.TryApiTokenAuth.call([])

      claims = Guardian.Plug.current_claims(conn)

      assert claims["sub"] == "foo@mbta.com"
      assert claims["typ"] == "access"
      assert claims["roles"] == ["admin"]
      assert Guardian.Plug.current_resource(conn) == "foo@mbta.com"
    end

    test "handles unexpected response from Cognito API", %{conn: conn} do
      reassign_env(:ex_aws_requester, {Fake.ExAws, :unexpected_response})

      token = Arrow.AuthToken.get_or_create_token_for_user("foo@mbta.com")

      log =
        capture_log([level: :warn], fn ->
          conn =
            conn
            |> put_req_header("x-api-key", token)
            |> ArrowWeb.TryApiTokenAuth.call([])

          claims = Guardian.Plug.current_claims(conn)

          assert claims["roles"] == []
        end)

      assert log =~ "unexpected_aws_api_response"
    end
  end
end
