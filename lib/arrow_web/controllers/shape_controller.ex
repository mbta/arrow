defmodule ArrowWeb.ShapeController do
  require Logger
  alias Arrow.Shuttles.ShapesUpload
  alias ArrowWeb.ErrorHelpers
  alias Ecto.Changeset
  use ArrowWeb, :controller

  alias Arrow.Shuttles
  alias ArrowWeb.Plug.Authorize

  plug(Authorize, :view_disruption when action in [:index, :show, :download])
  plug(Authorize, :create_disruption when action in [:new, :create])
  plug(Authorize, :update_disruption when action in [:edit, :update, :update_row_status])
  plug(Authorize, :delete_disruption when action in [:delete])

  def index(conn, _params) do
    shapes = Shuttles.list_shapes()
    render(conn, :index, shapes: shapes)
  end

  def new(conn, %{}) do
    changeset_map = ShapesUpload.changeset(%ShapesUpload{shapes: []}, %{})
    render(conn, :new_bulk, shapes_upload: changeset_map)
  end

  def create(conn, %{"shapes_upload" => shapes_upload}) do
    filename = shapes_upload["filename"].filename
    reset_upload = ShapesUpload.changeset(%ShapesUpload{shapes: []}, %{})

    with {:ok, saxy_shapes} <- ShapesUpload.parse_kml_from_file(shapes_upload),
         {:ok, shapes} <- ShapesUpload.shapes_from_kml(saxy_shapes),
         %Changeset{valid?: valid?} = changeset <-
           ShapesUpload.changeset(%ShapesUpload{}, %{filename: filename, shapes: shapes}) do
      if valid? do
        conn
        |> put_flash(
          :info,
          "Successfully parsed shapes #{inspect(shapes)} from file"
        )
        |> render(:select, form: changeset |> Phoenix.Component.to_form())
      else
        conn
        |> put_flash(
          :errors,
          {"Error parsing shapes from file", ErrorHelpers.changeset_error_messages(changeset)}
        )
        |> render(:new_bulk, errors: changeset.errors, shapes_upload: reset_upload)
      end
    else
      {:error, reason} ->
        conn
        |> put_flash(:errors, reason)
        |> render(:new_bulk, errors: reason, shapes_upload: reset_upload)
    end
  end

  def create(conn, %{"shapes" => shapes}) do
    reset_upload = ShapesUpload.changeset(%ShapesUpload{shapes: []}, %{})

    saved_shapes =
      shapes
      |> Enum.map(fn {_idx, shape} -> shape end)
      |> Enum.filter(fn shape -> shape["save"] == "true" end)
      |> Enum.map(fn shape -> %{name: shape["name"], coordinates: shape["coordinates"]} end)

    case Shuttles.create_shapes(saved_shapes) do
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
        |> render(:new_bulk, shapes_upload: reset_upload, errors: reason)
    end
  end

  def show(conn, %{"name" => name}) do
    shape = Shuttles.get_shape_by_name!(name)
    shape_upload = Shuttles.get_shapes_upload(shape)
    render(conn, :show, shape: shape, shape_upload: shape_upload)
  end

  def download(conn, %{"name" => name}) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    shape = Shuttles.get_shape_by_name!(name)
    basic_url = "https://#{shape.bucket}.s3.amazonaws.com/#{shape.path}"

    {:ok, url} =
      if enabled?,
        do: ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, shape.bucket, shape.path, []),
        else: {:ok, basic_url}

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header(
      "location",
      url
    )
  end

  def delete(conn, %{"name" => name}) do
    shape = Shuttles.get_shape_by_name!(name)
    {:ok, _shape} = Shuttles.delete_shape(shape)

    conn
    |> put_flash(:info, "Shape deleted successfully.")
    |> redirect(to: ~p"/shapes")
  end
end
