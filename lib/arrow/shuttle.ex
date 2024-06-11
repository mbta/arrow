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
    case upload_shape(attrs["filename"]) do
      {:ok, new_attrs} ->
        %Shape{}
        |> Shape.changeset(Enum.into(new_attrs, attrs))
        |> Repo.insert()

      {:error, e} ->
        {:error, e}
    end
  end

  defp upload_shape(%Plug.Upload{} = upload) do
    %{bucket: bucket, prefix: prefix} = Application.get_env(:arrow, :shape_storage)
    filename = upload.filename
    path = "#{prefix}#{filename}"

    # Check if file exists already:
    {:ok, check} = ExAws.S3.list_objects_v2(bucket, prefix: path) |> ExAws.request()

    if length(check.body.contents) > 0 do
      {:error, :already_exists}
    else
      {:ok, _} =
        upload.path
        |> ExAws.S3.Upload.stream_file()
        |> ExAws.S3.upload(bucket, path)
        |> ExAws.request()

      {:ok, %{"bucket" => bucket, "prefix" => prefix, "path" => path}}
    end
  end

  defp delete_shape_file(shape) do
    ExAws.S3.delete_object(shape.bucket, shape.path) |> ExAws.request()
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
    case upload_shape(attrs["filename"]) do
      {:ok, new_attrs} ->
        # Delete old file:
        {:ok, _} = delete_shape_file(shape)

        shape
        |> Shape.changeset(Enum.into(new_attrs, attrs))
        |> Repo.update()

      {:error, e} ->
        {:error, e}
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
    Repo.delete(shape)
    delete_shape_file(shape)
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
