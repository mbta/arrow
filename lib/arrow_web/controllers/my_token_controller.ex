defmodule ArrowWeb.MyTokenController do
  use ArrowWeb, :controller
  alias Arrow.AuthToken

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, _params) do
    token = conn |> get_session(:arrow_username) |> AuthToken.get_or_create_token_for_user()

    render(conn, "index.html", token: token)
  end
end
