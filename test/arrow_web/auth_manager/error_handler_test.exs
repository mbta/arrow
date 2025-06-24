defmodule ArrowWeb.AuthManager.ErrorHandlerTest do
  use ArrowWeb.ConnCase

  alias ArrowWeb.AuthManager.ErrorHandler

  describe "auth_error/3" do
    test "redirects to login if there's no refresh key", %{conn: conn} do
      provider = Application.get_env(:arrow, :ueberauth_provider)

      conn =
        conn
        |> init_test_session(%{})
        |> ErrorHandler.auth_error({:some_type, :reason}, [])

      assert html_response(conn, 302) =~ "\"/auth/#{provider}?prompt=login\""
    end

    test "adds auth_orig_path to session if request is a GET" do
      provider = Application.get_env(:arrow, :ueberauth_provider)

      conn =
        :get
        |> build_conn("/some/path")
        |> init_test_session(%{})
        |> ErrorHandler.auth_error({:some_type, :reason}, [])

      assert get_session(conn, :auth_orig_path) == "/some/path"
      assert html_response(conn, 302) =~ "\"/auth/#{provider}?prompt=login\""
    end

    test "adds auth_orig_path to session if request is a POST" do
      provider = Application.get_env(:arrow, :ueberauth_provider)

      conn =
        :post
        |> build_conn("/some/path")
        |> init_test_session(%{})
        |> ErrorHandler.auth_error({:some_type, :reason}, [])

      assert is_nil(get_session(conn, :auth_orig_path))
      assert html_response(conn, 302) =~ "\"/auth/#{provider}?prompt=login\""
    end
  end
end
