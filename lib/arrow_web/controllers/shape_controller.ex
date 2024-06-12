defmodule ArrowWeb.ShapeController do
  require Logger
  alias Arrow.Shuttle.ShapeUpload
  use ArrowWeb, :controller

  alias Arrow.Shuttle
  alias ArrowWeb.Plug.Authorize

  plug(Authorize, :view_disruption when action in [:index, :show])
  plug(Authorize, :create_disruption when action in [:new, :create])
  plug(Authorize, :update_disruption when action in [:edit, :update, :update_row_status])
  plug(Authorize, :delete_disruption when action in [:delete])

  def index(conn, _params) do
    shapes = Shuttle.list_shapes()
    render(conn, :index, shapes: shapes)
  end

  def new(conn, %{}) do
    changeset_map = ShapeUpload.changeset(%ShapeUpload{shapes: %{}}, %{})
    render(conn, :new_bulk, shape_upload: changeset_map)
  end

  def create(conn, %{"shape_upload" => shape_upload}) do
    with {:ok, saxy_shapes} <- ShapeUpload.parse_kml_from_file(shape_upload),
         {:ok, shapes} <- ShapeUpload.shapes_from_kml(saxy_shapes),
         {:ok, changesets} <- Shuttle.create_shapes(shapes) do
      conn
      |> put_flash(
        :info,
        "Uploaded successfully #{inspect(changesets)}"
      )
      |> redirect(to: ~p"/shapes/")
    else
      {:error, reason} ->
        conn
        |> put_flash(
          :errors,
          reason
        )
        |> render(:new_bulk, shape_upload: shape_upload, errors: reason)
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
        |> put_flash(
          :info,
          "Shape name updated successfully"
        )
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
