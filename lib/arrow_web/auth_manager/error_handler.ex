defmodule ArrowWeb.AuthManager.ErrorHandler do
  @moduledoc """
  Plug to handle if user is not authenticated.
  """

  alias ArrowWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, error, _opts) do
    provider = Application.get_env(:arrow, :ueberauth_provider)
    auth_params = auth_params_for_error(error)

    conn
    |> maybe_put_auth_orig_path(conn)
    |> Controller.redirect(to: Routes.auth_path(conn, :request, "#{provider}", auth_params))
  end

  defp maybe_put_auth_orig_path(conn, original_conn) do
    if original_conn.method == "GET" do
      Plug.Conn.put_session(conn, :auth_orig_path, original_conn.request_path)
    else
      conn
    end
  end

  def auth_params_for_error({:invalid_token, {:auth_expired, sub}}) do
    # if we know the user who was logged in before, provide that upstream to simplify
    # logging in
    %{
      prompt: "login",
      login_hint: sub
    }
  end

  def auth_params_for_error({:unauthenticated, _}) do
    %{}
  end

  def auth_params_for_error(_) do
    %{
      prompt: "login"
    }
  end
end
