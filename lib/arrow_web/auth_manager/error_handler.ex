defmodule ArrowWeb.AuthManager.ErrorHandler do
  @moduledoc """
  Plug to handle if user is not authenticated.
  """

  alias ArrowWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {_type, _reason}, _opts) do
    provider = Application.get_env(:arrow, :ueberauth_provider)
    Controller.redirect(conn, to: Routes.auth_path(conn, :request, "#{provider}"))
  end
end
