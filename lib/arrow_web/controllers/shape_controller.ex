defmodule ArrowWeb.ShapeController do
  use ArrowWeb, :controller

  alias Arrow.Shuttle
  alias Arrow.Shuttle.Shape
  alias ArrowWeb.Plug.Authorize

  plug(Authorize, :view_disruption when action in [:index, :show, :download])
  plug(Authorize, :create_disruption when action in [:new, :create])
  plug(Authorize, :update_disruption when action in [:edit, :update, :update_row_status])
  plug(Authorize, :delete_disruption when action in [:delete])

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
        |> put_flash(
          :info,
          "Shape created successfully from #{shape_params["filename"].filename}"
        )
        |> redirect(to: ~p"/shapes/#{shape}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)

      {:error, :already_exists} ->
        conn
        |> put_flash(
          :error,
          "#{shape_params["filename"].filename} already exists on the server."
        )
        |> redirect(to: ~p"/shapes/new")
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

  def download(conn, %{"id" => id}) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    shape = Shuttle.get_shape!(id)
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

  def update(conn, %{"id" => id, "shape" => shape_params}) do
    shape = Shuttle.get_shape!(id)

    case Shuttle.update_shape(shape, shape_params) do
      {:ok, shape} ->
        conn
        |> put_flash(
          :info,
          "Shape updated successfully from #{shape_params["filename"].filename}"
        )
        |> redirect(to: ~p"/shapes/#{shape}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, shape: shape, changeset: changeset)

      {:error, :already_exists} ->
        conn
        |> put_flash(
          :error,
          "#{shape_params["filename"].filename} already exists on the server."
        )
        |> redirect(to: ~p"/shapes/#{shape}")
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
