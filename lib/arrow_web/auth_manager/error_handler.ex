defmodule ArrowWeb.AuthManager.ErrorHandler do
  @moduledoc """
  Plug to handle if user is not authenticated.
  """

  alias ArrowWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    Controller.redirect(conn, to: Routes.auth_path(conn, :request, "cognito"))
  end
end
