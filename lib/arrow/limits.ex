defmodule Arrow.Limits do
  @moduledoc """
  The Limits context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Disruptions.Limit

  @preloads [:route, :start_stop, :end_stop]

  @doc """
  Returns the list of limits.

  ## Examples

      iex> list_limits()
      [%Limit{}, ...]

  """
  def list_limits do
    Limit |> Repo.all() |> Repo.preload(@preloads)
  end

  @doc """
  Gets a single limit.

  Raises `Ecto.NoResultsError` if the Limit does not exist.

  ## Examples

      iex> get_limit!(123)
      %Limit{}

      iex> get_limit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_limit!(id), do: Limit |> Repo.get!(id) |> Repo.preload(@preloads)

  @doc """
  Creates a limit.

  ## Examples

      iex> create_limit(%{field: value})
      {:ok, %Limit{}}

      iex> create_limit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_limit(attrs \\ %{}) do
    %Limit{}
    |> Limit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a limit.

  ## Examples

      iex> update_limit(limit, %{field: new_value})
      {:ok, %Limit{}}

      iex> update_limit(limit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_limit(%Limit{} = limit, attrs) do
    limit
    |> Limit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a limit.

  ## Examples

      iex> delete_limit(limit)
      {:ok, %Limit{}}

      iex> delete_limit(limit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_limit(%Limit{} = limit) do
    Repo.delete(limit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking limit changes.

  ## Examples

      iex> change_limit(limit)
      %Ecto.Changeset{data: %Limit{}}

  """
  def change_limit(%Limit{} = limit, attrs \\ %{}) do
    Limit.changeset(limit, attrs)
  end
end
