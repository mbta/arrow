defmodule ArrowWeb.API.DBDumpController do
  alias ArrowWeb.Plug.Authorize
  use ArrowWeb, :controller

  plug(Authorize, :db_dump)

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, _params) do
    json(conn, Arrow.DBStructure.dump_data())
  end
end
