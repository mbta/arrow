defmodule ArrowWeb.AuthManager.ErrorHandlerTest do
  use ArrowWeb.ConnCase

  describe "auth_error/3" do
    test "redirects to login if there's no refresh key", %{conn: conn} do
      provider = Application.get_env(:arrow, :ueberauth_provider)

      conn =
        conn
        |> init_test_session(%{})
        |> ArrowWeb.AuthManager.ErrorHandler.auth_error({:some_type, :reason}, [])

      assert html_response(conn, 302) =~ "\"/auth/#{provider}\""
    end
  end
end
