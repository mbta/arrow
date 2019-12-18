defmodule ArrowWeb.AuthManager.ErrorHandlerTest do
  use ArrowWeb.ConnCase
  use Plug.Test

  describe "auth_error/3" do
    test "returns 401 response with error", %{conn: conn} do
      conn =
        conn
        |> init_test_session(%{})
        |> ArrowWeb.AuthManager.ErrorHandler.auth_error({:some_type, :reason}, [])

      assert text_response(conn, 401) =~ "some_type"
    end
  end
end
