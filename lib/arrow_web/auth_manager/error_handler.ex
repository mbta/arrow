defmodule ArrowWeb.AuthManager.ErrorHandler do
  @moduledoc """
  Plug to handle if user is not authenticated.
  """

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    Phoenix.Controller.redirect(
      conn,
      to: ArrowWeb.Router.Helpers.auth_path(conn, :request, "cognito")
    )
  end
end
