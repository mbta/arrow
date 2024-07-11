defmodule Arrow.Shuttle do
  @moduledoc """
  The Shuttle context.
  """

  import Ecto.Query, warn: false

  alias Arrow.Repo
  alias ArrowWeb.ErrorHelpers

  alias Arrow.Shuttle.Shape

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
          |> Enum.map(fn {_, changeset} ->
            "#{ErrorHelpers.changeset_error_messages(changeset)} for #{changeset.changes.name}"
          end)

        {:error, {"Failed to upload some shapes", errors}}
    end
  end

  @doc """
  Creates a shape.

  ## Examples

      iex> create_shape(%{field: value})
      {:ok, %Shape{}}

      iex> create_shape(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shape(attrs \\ %{}) do
    case upload_shape_file(attrs) do
      {:ok, new_attrs} ->
        do_create_shape(Enum.into(new_attrs, attrs))

      {:error, e} ->
        {:error, e}
    end
  end

  defp do_create_shape(attrs) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  defp upload_shape_file(%{"filename" => %Plug.Upload{} = upload}) do
    upload_shape_file(%{name: upload.filename, content: File.read!(upload.path)})
  end

  defp upload_shape_file(%{name: name, coordinates: content}) do
    upload_shape_file(%{name: name, content: content})
  end

  defp upload_shape_file(%{name: name, content: content}) do
    prefix = Application.get_env(:arrow, :shape_storage_prefix)
    bucket = Application.get_env(:arrow, :shape_storage_bucket)
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    prefix_env = Application.get_env(:arrow, :shape_storage_prefix_env)
    request_fn = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? and prefix_env != nil do
      prefix_env_value = System.get_env(prefix_env)
      filename = "#{name}.kml"

      path =
        if prefix_env_value,
          do: "#{prefix}#{prefix_env_value}/#{filename}",
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

    if enabled? do
      ExAws.S3.delete_object(shape.bucket, shape.path) |> ExAws.request()
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
end
