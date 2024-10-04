defmodule Arrow.Shuttles do
  @moduledoc """
  The Shuttles context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Shuttles.Shuttle

  @doc """
  Returns the list of shuttles.

  ## Examples

      iex> list_shuttles()
      [%Shuttle{}, ...]

  """
  def list_shuttles do
    Repo.all(Shuttle)
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
  def get_shuttle!(id), do: Repo.get!(Shuttle, id)

  @doc """
  Creates a shuttle.

  ## Examples

      iex> create_shuttle(%{field: value})
      {:ok, %Shuttle{}}

      iex> create_shuttle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shuttle(attrs \\ %{}) do
    %Shuttle{}
    |> Shuttle.changeset(attrs)
    |> Repo.insert()
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
    shuttle
    |> Shuttle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shuttle.

  ## Examples

      iex> delete_shuttle(shuttle)
      {:ok, %Shuttle{}}

      iex> delete_shuttle(shuttle)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shuttle(%Shuttle{} = shuttle) do
    Repo.delete(shuttle)
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
end
