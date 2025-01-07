defmodule ArrowWeb.EnsureArrowReadOnly do
  @moduledoc """
  Verify user has read-only access to Arrow.
  """

  use ArrowWeb, :verified_routes

  import Plug.Conn, only: [halt: 1]
  import Phoenix.Controller, only: [redirect: 2]

  @read_only_roles MapSet.new(["read-only", "admin"])

  def init(options), do: options

  def call(%{assigns: %{current_user: user}} = conn, _opts) do
    if MapSet.disjoint?(user.roles, @read_only_roles) do
      conn
      |> redirect(to: ~p"/unauthorized")
      |> halt()
    else
      conn
    end
  end
end
