defmodule Arrow.Shuttle do
  @moduledoc """
  The Shuttle context.
  """

  import Ecto.Query, warn: false

  alias Arrow.Repo

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
  Creates a shape.

  ## Examples

      iex> create_shape(%{field: value})
      {:ok, %Shape{}}

      iex> create_shape(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shape(attrs \\ %{}) do
    if Map.has_key?(attrs, "filename") do
      case upload_shape(attrs["filename"]) do
        {:ok, new_attrs} ->
          do_create_shape(Enum.into(new_attrs, attrs))

        {:error, e} ->
          {:error, e}
      end
    else
      do_create_shape(attrs)
    end
  end

  defp do_create_shape(attrs) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  defp upload_shape(%Plug.Upload{} = upload) do
    %{bucket: bucket, prefix: prefix, enabled?: enabled?, prefix_env: prefix_env} =
      Application.get_env(:arrow, :shape_storage)

    if enabled? do
      prefix_env_value = System.get_env(prefix_env)
      filename = upload.filename

      path =
        if prefix_env_value,
          do: "#{prefix}#{prefix_env_value}/#{filename}",
          else: "#{prefix}#{filename}"

      case do_upload_shape(upload.path, bucket, path) do
        error = {:error, _} -> error
        {:ok, _} -> {:ok, %{"bucket" => bucket, "prefix" => prefix, "path" => path}}
      end
    else
      {:ok, %{"bucket" => "disabled", "prefix" => "disabled", "path" => "disabled"}}
    end
  end

  defp do_upload_shape(local_path, bucket, remote_path) do
    # Check if file exists already:
    {:ok, check} = ExAws.S3.list_objects_v2(bucket, prefix: remote_path) |> ExAws.request()

    if length(check.body.contents) > 0 do
      {:error, :already_exists}
    else
      {:ok, _} =
        local_path
        |> ExAws.S3.Upload.stream_file()
        |> ExAws.S3.upload(bucket, remote_path)
        |> ExAws.request()
    end
  end

  defp delete_shape_file(shape) do
    %{enabled?: enabled?} = Application.get_env(:arrow, :shape_storage)

    if enabled? do
      ExAws.S3.delete_object(shape.bucket, shape.path) |> ExAws.request()
    else
      {:ok, :disabled}
    end
  end

  @doc """
  Updates a shape.

  ## Examples

      iex> update_shape(shape, %{field: new_value})
      {:ok, %Shape{}}

      iex> update_shape(shape, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shape(%Shape{} = shape, attrs) do
    if Map.has_key?(attrs, "filename") do
      case upload_shape(attrs["filename"]) do
        {:ok, new_attrs} ->
          # Delete old file:
          {:ok, _} = delete_shape_file(shape)
          do_shape_update(shape, Enum.into(new_attrs, attrs))

        {:error, e} ->
          {:error, e}
      end
    else
      do_shape_update(shape, attrs)
    end
  end

  defp do_shape_update(shape, attrs) do
    shape
    |> Shape.changeset(attrs)
    |> Repo.update()
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
