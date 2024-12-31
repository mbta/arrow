defmodule ArrowWeb.MyTokenController do
  use ArrowWeb, :controller
  alias Arrow.AuthToken

  @spec show(Plug.Conn.t(), Plug.Conn.params()) :: Plug.Conn.t()
  def show(conn, _params) do
    token = conn |> Guardian.Plug.current_resource() |> AuthToken.get_or_create_token_for_user()

    render(conn, "index.html", token: token)
  end
end
