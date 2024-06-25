defmodule ArrowWeb.ShapeController do
  require Logger
  alias Ecto.Changeset
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
    changeset_map = ShapeUpload.changeset(%ShapeUpload{shapes: []}, %{})
    render(conn, :new_bulk, shape_upload: changeset_map)
  end

  def create(conn, %{"shape_upload" => shape_upload}) do
    filename = shape_upload["filename"].filename

    with {:ok, saxy_shapes} <- ShapeUpload.parse_kml_from_file(shape_upload),
         {:ok, shapes} <- ShapeUpload.shapes_from_kml(saxy_shapes),
         %Changeset{valid?: true} = changeset <-
           ShapeUpload.changeset(%ShapeUpload{}, %{filename: filename, shapes: shapes}) do
      conn
      |> put_flash(
        :info,
        "Successfully parsed shapes #{inspect(shapes)} from file"
      )
      |> render(:select, form: changeset |> Phoenix.Component.to_form())
    else
      {:error, reason} ->
        conn
        |> put_flash(:errors, reason)
        |> render(:new_bulk, shape_upload: shape_upload, errors: reason)

      error ->
        conn
        |> put_flash(:errors, error)
        |> render(:new_bulk, shape_upload: shape_upload, errors: error)
    end
  end

  def create(conn, %{"shapes" => shapes} = shape_upload) do
    saved_shapes =
      shapes
      |> Enum.map(fn {_idx, shape} -> shape end)
      |> Enum.filter(fn shape -> shape["save"] == "true" end)

    case Shuttle.create_shapes(saved_shapes) do
      {:ok, []} ->

        conn
        |> put_flash(
          :info,
          "No shapes were marked to be saved"
        )
        |> redirect(to: ~p"/shapes/")

      {:ok, changesets} ->

        saved_shape_names =
          changesets
          |> Enum.map(fn {:ok, changeset} -> changeset.name end)

        conn
        |> put_flash(
          :info,
          "Successfully saved shapes: #{inspect(saved_shape_names)}"
        )
        |> redirect(to: ~p"/shapes/")

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
