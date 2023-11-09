defmodule ArrowWeb.Plug.AssignUser do
  @moduledoc """
  Associates a connection with an `Arrow.Account.User`.
  """
  import Plug.Conn
  alias Arrow.Accounts.User

  @spec init(Plug.opts()) :: Plug.opts()
  def init(options), do: options

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    %{"sub" => user_id, "roles" => roles} = Guardian.Plug.current_claims(conn)

    assign(conn, :current_user, %User{
      id: user_id,
      roles: MapSet.new(roles)
    })
  end
end
