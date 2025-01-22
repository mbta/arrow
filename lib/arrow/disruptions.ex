defmodule Arrow.Disruptions do
  @moduledoc """
  The Disruptions context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Disruptions.DisruptionV2

  @preloads [replacement_services: [:shuttle]]

  @doc """
  Returns the list of disruptionsv2.

  ## Examples

      iex> list_disruptionsv2()
      [%DisruptionV2{}, ...]

  """
  def list_disruptionsv2 do
    DisruptionV2 |> Repo.all() |> Repo.preload(@preloads)
  end

  @doc """
  Gets a single disruption_v2.

  Raises `Ecto.NoResultsError` if the Disruption v2 does not exist.

  ## Examples

      iex> get_disruption_v2!(123)
      %DisruptionV2{}

      iex> get_disruption_v2!(456)
      ** (Ecto.NoResultsError)

  """
  def get_disruption_v2!(id), do: DisruptionV2 |> Repo.get!(id) |> Repo.preload(@preloads)

  @doc """
  Creates a disruption_v2.

  ## Examples

      iex> create_disruption_v2(%{field: value})
      {:ok, %DisruptionV2{}}

      iex> create_disruption_v2(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_disruption_v2(attrs \\ %{}) do
    %DisruptionV2{}
    |> DisruptionV2.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a disruption_v2.

  ## Examples

      iex> update_disruption_v2(disruption_v2, %{field: new_value})
      {:ok, %DisruptionV2{}}

      iex> update_disruption_v2(disruption_v2, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_disruption_v2(%DisruptionV2{} = disruption_v2, attrs) do
    disruption_v2
    |> DisruptionV2.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a disruption_v2.

  ## Examples

      iex> delete_disruption_v2(disruption_v2)
      {:ok, %DisruptionV2{}}

      iex> delete_disruption_v2(disruption_v2)
      {:error, %Ecto.Changeset{}}

  """
  def delete_disruption_v2(%DisruptionV2{} = disruption_v2) do
    Repo.delete(disruption_v2)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking disruption_v2 changes.

  ## Examples

      iex> change_disruption_v2(disruption_v2)
      %Ecto.Changeset{data: %DisruptionV2{}}

  """
  def change_disruption_v2(%DisruptionV2{} = disruption_v2, attrs \\ %{}) do
    DisruptionV2.changeset(disruption_v2, attrs)
  end
end
