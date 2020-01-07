defmodule ArrowWeb.EditController do
  @moduledoc """
  """
  use ArrowWeb, :controller

  def index(conn, %{"id" => disruption_id}) do
    data = disruption_id
    render(conn, "edit.html", data: data)
  end

  def index(conn, _params) do
    render(conn, "edit.html")
  end
end
