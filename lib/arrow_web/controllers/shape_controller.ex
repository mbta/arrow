defmodule ArrowWeb.ShapeController do
  use ArrowWeb, :controller

  alias Arrow.Shuttle
  alias Arrow.Shuttle.Shape

  def index(conn, _params) do
    shapes = Shuttle.list_shapes()
    render(conn, :index, shapes: shapes)
  end

  def new(conn, _params) do
    changeset = Shuttle.change_shape(%Shape{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"shape" => shape_params}) do
    case Shuttle.create_shape(shape_params) do
      {:ok, shape} ->
        conn
        |> put_flash(:info, "Shape created successfully.")
        |> redirect(to: ~p"/shapes/#{shape}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shape = Shuttle.get_shape!(id)
    render(conn, :show, shape: shape)
  end

  def edit(conn, %{"id" => id}) do
    shape = Shuttle.get_shape!(id)
    changeset = Shuttle.change_shape(shape)
    render(conn, :edit, shape: shape, changeset: changeset)
  end

  def update(conn, %{"id" => id, "shape" => shape_params}) do
    shape = Shuttle.get_shape!(id)

    case Shuttle.update_shape(shape, shape_params) do
      {:ok, shape} ->
        conn
        |> put_flash(:info, "Shape updated successfully.")
        |> redirect(to: ~p"/shapes/#{shape}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shape: shape, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shape = Shuttle.get_shape!(id)
    {:ok, _shape} = Shuttle.delete_shape(shape)

    conn
    |> put_flash(:info, "Shape deleted successfully.")
    |> redirect(to: ~p"/shapes")
  end
end
