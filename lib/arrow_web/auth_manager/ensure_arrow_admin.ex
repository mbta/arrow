defmodule ArrowWeb.EnsureArrowAdmin do
  @moduledoc """
  Verify user is an Arrow admin.
  """

  use ArrowWeb, :verified_routes

  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [redirect: 2]

  def init(options), do: options

  def call(%{assigns: %{current_user: user}} = conn, _opts) do
    if "admin" in user.roles do
      conn
    else
      conn
      |> redirect(to: ~p"/unauthorized")
      |> halt()
    end
  end
end
