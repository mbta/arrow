defmodule ArrowWeb.Plug.Authorize do
  @moduledoc """
  Checks a user's permissions and sends them a 403 if they are unauthorized.
  """
  import Plug.Conn
  alias Arrow.Accounts.User
  alias Arrow.Permissions
  alias ArrowWeb.Router.Helpers, as: Routes
  alias Phoenix.Controller

  @spec init(Plug.opts()) :: Plug.opts()
  def init(options), do: options

  @spec call(Plug.Conn.t(), Permissions.action()) :: Plug.Conn.t()
  def call(%Plug.Conn{assigns: %{current_user: %User{} = user}} = conn, action) do
    case Permissions.authorize(action, user) do
      :ok ->
        conn

      _ ->
        conn
        |> Controller.redirect(to: Routes.unauthorized_path(conn, :index))
        |> halt()
    end
  end
end
