defmodule ArrowWeb.DisruptionController do
  use ArrowWeb, :controller

  alias __MODULE__.{Filters, Index}

  def index(conn, params) do
    filters = Filters.from_params(params)
    render(conn, "index.html", disruptions: Index.all(filters), filters: filters)
  end

  def show(conn, %{"id" => id}) do
    render(conn, "show.html", id: id)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def edit(conn, %{"id" => id}) do
    render(conn, "edit.html", id: id)
  end
end
