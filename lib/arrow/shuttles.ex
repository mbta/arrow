defmodule Arrow.Shuttles do
  @moduledoc """
  The Shuttles context.
  """

  import Ecto.Query, warn: false

  alias Arrow.Repo
  alias ArrowWeb.ErrorHelpers

  alias Arrow.Gtfs.Route, as: GtfsRoute
  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles.KML
  alias Arrow.Shuttles.Shape
  alias Arrow.Shuttles.ShapesUpload
  alias Arrow.Shuttles.ShapeUpload
  alias Arrow.Shuttles.Stop

  @doc """
  Returns the list of shapes.

  ## Examples

      iex> list_shapes()
      [%Shape{}, ...]

  """
  def list_shapes do
    Repo.all(Shape)
  end

  @doc """
  Gets a single shape.

  Raises `Ecto.NoResultsError` if the Shape does not exist.

  ## Examples

      iex> get_shape!(123)
      %Shape{}

      iex> get_shape!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shape!(id), do: Repo.get!(Shape, id)

  @doc """
  Gets a shapes upload struct associated with a given shape.

  ## Examples

      iex> get_shapes_upload(%Shape{})
      %ShapesUpload{}
  """
  def get_shapes_upload(%Shape{} = shape) do
    with true <- Application.get_env(:arrow, :shape_storage_enabled?),
         {:ok, %{body: shapes_kml}} <- get_shape_file(shape),
         {:ok, parsed_shapes} <- ShapesUpload.parse_kml(shapes_kml),
         {:ok, shapes} <- ShapesUpload.shapes_from_kml(parsed_shapes) do
      ShapesUpload.changeset(%ShapesUpload{}, %{filename: shape.name, shapes: shapes})
    else
      false -> {:ok, :disabled}
      error -> error
    end
  end

  defp get_shape_file(shape) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    {request_module, request_func} = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? do
      get_request = ExAws.S3.get_object(shape.bucket, shape.path)
      apply(request_module, request_func, [get_request])
    else
      {:ok, :disabled}
    end
  end

  @spec create_shapes(any()) :: {:error, {<<_::224>>, list()}} | {:ok, list()}
  @doc """
  Creates shapes.

  """
  def create_shapes(shapes) do
    changesets = Enum.map(shapes, fn shape -> create_shape(shape) end)

    case Enum.all?(changesets, fn changeset -> Kernel.match?({:ok, _shape}, changeset) end) do
      true ->
        {:ok, changesets}

      _ ->
        errors =
          changesets
          |> Enum.filter(fn changeset -> Kernel.match?({:error, _}, changeset) end)
          |> Enum.map(&handle_create_error/1)

        {:error, {"Failed to upload some shapes", errors}}
    end
  end

  def handle_create_error({_, message}) when is_binary(message) do
    message
  end

  def handle_create_error({_, %Ecto.Changeset{} = changeset}) do
    "#{ErrorHelpers.changeset_error_messages(changeset)} #{changeset.params["name"]}"
  end

  @doc """
  Creates a shape.

  ## Examples

      iex> create_shape(%{field: value})
      {:ok, %Shape{}}

      iex> create_shape(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shape(attrs) do
    with {:ok, attrs} <- Shape.validate_and_enforce_name(attrs),
         nil <- Repo.get_by(Shape, name: attrs.name),
         {:ok, shape_with_kml} <- create_shape_kml(attrs),
         {:ok, new_attrs} <- upload_shape_file(shape_with_kml) do
      do_create_shape(Enum.into(new_attrs, attrs))
    else
      %Shape{name: name} ->
        {:error, "Shape #{name} already exists, delete the shape to save a new one"}

      {:error, :already_exists} ->
        {:error,
         "File for shape #{attrs.name} already exists, delete the shape to save a new one"}

      {:error, e} ->
        {:error, e}
    end
  end

  defp do_create_shape(attrs) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  def create_shape_kml(%{name: _name, coordinates: _coordinates} = attrs) do
    kml = %KML{xmlns: "http://www.opengis.net/kml/2.2", Folder: attrs}
    shape_kml = Saxy.Builder.build(kml)
    content = Saxy.encode!(shape_kml, version: "1.0", encoding: "UTF-8")
    {:ok, Enum.into(%{content: content}, attrs)}
  end

  def create_shape_kml(attrs) do
    {:error, ShapeUpload.changeset(%ShapeUpload{}, attrs)}
  end

  defp upload_shape_file(%{name: name, content: content}) do
    prefix = Application.get_env(:arrow, :shape_storage_prefix)
    bucket = Application.get_env(:arrow, :shape_storage_bucket)
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    prefix_env = Application.get_env(:arrow, :shape_storage_prefix_env)
    request_fn = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? and prefix_env != nil do
      filename = "#{name}.kml"

      path =
        if prefix_env,
          do: "#{prefix_env}#{prefix}#{filename}",
          else: "#{prefix}#{filename}"

      case do_upload_shape(content, bucket, path, request_fn) do
        error = {:error, _} -> error
        {:ok, _} -> {:ok, %{bucket: bucket, prefix: prefix, path: path}}
      end
    else
      {:ok, %{bucket: "disabled", prefix: "disabled", path: "disabled"}}
    end
  end

  defp do_upload_shape(content, bucket, remote_path, request_fn) do
    {request_module, request_func} = request_fn
    # Check if file exists already:
    check_request = ExAws.S3.list_objects_v2(bucket, prefix: remote_path)
    {:ok, check} = apply(request_module, request_func, [check_request])

    if length(check.body.contents) > 0 do
      {:error, :already_exists}
    else
      upload_request = ExAws.S3.put_object(bucket, remote_path, content)
      {:ok, _} = apply(request_module, request_func, [upload_request])
    end
  end

  defp delete_shape_file(shape) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    {request_module, request_func} = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? do
      delete_request = ExAws.S3.delete_object(shape.bucket, shape.path)
      apply(request_module, request_func, [delete_request])
    else
      {:ok, :disabled}
    end
  end

  @doc """
  Deletes a shape.

  ## Examples

      iex> delete_shape(shape)
      {:ok, %Shape{}}

      iex> delete_shape(shape)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shape(%Shape{} = shape) do
    {:ok, _} = delete_shape_file(shape)
    Repo.delete(shape)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shape changes.

  ## Examples

      iex> change_shape(shape)
      %Ecto.Changeset{data: %Shape{}}

  """
  def change_shape(%Shape{} = shape, attrs \\ %{}) do
    Shape.changeset(shape, attrs)
  end

  alias Arrow.Shuttles.Shuttle

  @doc """
  Returns the list of shuttles.

  ## Examples

      iex> list_shuttles()
      [%Shuttle{}, ...]

  """
  def list_shuttles do
    Repo.all(Shuttle) |> Repo.preload(routes: [:shape])
  end

  @doc """
  Gets a single shuttle.

  Raises `Ecto.NoResultsError` if the Shuttle does not exist.

  ## Examples

      iex> get_shuttle!(123)
      %Shuttle{}

      iex> get_shuttle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shuttle!(id) do
    Repo.get!(Shuttle, id) |> Repo.preload(routes: [:shape])
  end

  @doc """
  Creates a shuttle.

  ## Examples

      iex> create_shuttle(%{field: value})
      {:ok, %Shuttle{}}

      iex> create_shuttle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shuttle(attrs \\ %{}) do
    created_shuttle =
      %Shuttle{}
      |> Shuttle.changeset(attrs)
      |> Repo.insert()

    case created_shuttle do
      {:ok, shuttle} -> {:ok, Repo.preload(shuttle, routes: [:shape])}
      err -> err
    end
  end

  @doc """
  Updates a shuttle.

  ## Examples

      iex> update_shuttle(shuttle, %{field: new_value})
      {:ok, %Shuttle{}}

      iex> update_shuttle(shuttle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shuttle(%Shuttle{} = shuttle, attrs) do
    updated_shuttle =
      shuttle
      |> Shuttle.changeset(attrs)
      |> Repo.update()

    case updated_shuttle do
      {:ok, shuttle} -> {:ok, Repo.preload(shuttle, routes: [:shape])}
      err -> err
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shuttle changes.

  ## Examples

      iex> change_shuttle(shuttle)
      %Ecto.Changeset{data: %Shuttle{}}

  """
  def change_shuttle(%Shuttle{} = shuttle, attrs \\ %{}) do
    Shuttle.changeset(shuttle, attrs)
  end

  def list_disruptable_routes do
    query = from(r in GtfsRoute, where: r.type in [:light_rail, :heavy_rail])
    Repo.all(query)
  end

  @doc """
  Given a stop ID, returns either an Arrow-created stop, or a
  stop from GTFS. Prefers the Arrow-created stop if both are
  present.
  """
  @spec stop_or_gtfs_stop_for_stop_id(String.t()) :: Stop.t() | GtfsStop.t() | nil
  def stop_or_gtfs_stop_for_stop_id(id) do
    case Repo.get_by(Stop, stop_id: id) do
      nil -> Repo.get(GtfsStop, id)
      stop -> stop
    end
  end
end
