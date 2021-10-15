defmodule ArrowWeb.Plug.AssignUser do
  @moduledoc """
  Associates a connection with an `Arrow.Account.User`.
  """
  import Plug.Conn
  alias Arrow.Accounts.User

  @cognito_groups Application.compile_env!(:arrow, :cognito_groups)

  @spec init(Plug.opts()) :: Plug.opts()
  def init(options), do: options

  @spec call(Plug.Conn.t(), Plug.opts()) :: Plug.Conn.t()
  def call(conn, _opts) do
    %{"sub" => user_id} = claims = Guardian.Plug.current_claims(conn)

    groups =
      claims
      |> Map.get("groups", [])
      |> Enum.map(&@cognito_groups[&1])
      |> Enum.reject(&is_nil/1)

    assign(conn, :current_user, %User{
      id: user_id,
      groups: MapSet.new(groups)
    })
  end
end
