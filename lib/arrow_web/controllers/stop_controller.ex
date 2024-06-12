defmodule ArrowWeb.StopController do
  use ArrowWeb, :controller

  alias Plug.Conn

  @spec index(Conn.t(), Conn.params()) :: Conn.t()
  def index(conn, _params) do
    render(conn, "index.html", [])
  end

  @spec new(Conn.t(), Conn.params()) :: Conn.t()
  def new(conn, _params) do
    render(conn, "new.html", [])
  end

  @spec create(Conn.t(), Conn.params()) :: Conn.t()
  def create(conn, _params) do
    render(conn, "new.html", [])
  end

  @spec edit(Conn.t(), Conn.params()) :: Conn.t()
  def edit(conn, _parmas) do
    render(conn, "edit.html", [])
  end

  @spec update(Conn.t(), Conn.params()) :: Conn.t()
  def update(conn, %{"id" => _id} = _params) do
    render(conn, "edit.html", [])
  end
end
