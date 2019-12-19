defmodule ArrowWeb.EnsureArrowGroup do
  import Plug.Conn

  def init(options), do: options

  def call(conn, _opts) do
    with %{"groups" => groups} <- Guardian.Plug.current_claims(conn),
         true <- is_list(groups),
         arrow_group <- Application.get_env(:arrow, :cognito_group),
         true <- arrow_group in groups do
      conn
    else
      _ ->
        conn
        |> Phoenix.Controller.redirect(
          to: ArrowWeb.Router.Helpers.unauthorized_path(conn, :index)
        )
        |> halt()
    end
  end
end
