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
            ErrorHelpers.changeset_error_messages(changeset)
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
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
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
