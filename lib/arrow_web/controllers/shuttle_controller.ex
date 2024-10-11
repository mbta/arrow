defmodule ArrowWeb.ShuttleController do
  use ArrowWeb, :controller
  alias Arrow.Shuttles.Shuttle

  def index(conn, _params) do
    render(conn, :index, shuttles: [])
  end

  def new(conn, _params) do
    render(conn, :new, changeset: nil)
  end

  def create(conn, %{"shuttle" => _shuttle_params}) do
    render(conn, :new, changeset: nil)
  end

  def show(conn, %{"id" => _id}) do
    render(conn, :show, shuttle: nil)
  end

  def edit(conn, %{"id" => id}) do
    render(conn, :edit, shuttle: %Shuttle{id: id}, changeset: nil)
  end

  def update(conn, %{"id" => _id, "shuttle" => _shuttle_params}) do
    render(conn, :edit, shuttle: nil, changeset: nil)
  end
end
