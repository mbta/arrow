defmodule Arrow.Disruptions do
  @moduledoc """
  The Disruptions context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Disruptions.DisruptionV2

  @preloads [
    limits: [:route, :start_stop, :end_stop, :limit_day_of_weeks],
    replacement_services: [:shuttle]
  ]

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

  alias Arrow.Disruptions.ReplacementService

  @doc """
  Returns the list of replacement_services.

  ## Examples

      iex> list_replacement_services()
      [%ReplacementService{}, ...]

  """
  def list_replacement_services do
    Repo.all(ReplacementService)
  end

  @doc """
  Gets a single replacement_service.

  Raises `Ecto.NoResultsError` if the Replacement service does not exist.

  ## Examples

      iex> get_replacement_service!(123)
      %ReplacementService{}

      iex> get_replacement_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_replacement_service!(id), do: Repo.get!(ReplacementService, id)

  @doc """
  Creates a replacement_service.

  ## Examples

      iex> create_replacement_service(%{field: value})
      {:ok, %ReplacementService{}}

      iex> create_replacement_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_replacement_service(attrs \\ %{}) do
    %ReplacementService{}
    |> ReplacementService.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a replacement_service.

  ## Examples

      iex> update_replacement_service(replacement_service, %{field: new_value})
      {:ok, %ReplacementService{}}

      iex> update_replacement_service(replacement_service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_replacement_service(%ReplacementService{} = replacement_service, attrs) do
    replacement_service
    |> ReplacementService.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a replacement_service.

  ## Examples

      iex> delete_replacement_service(replacement_service)
      {:ok, %ReplacementService{}}

      iex> delete_replacement_service(replacement_service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_replacement_service(%ReplacementService{} = replacement_service) do
    Repo.delete(replacement_service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking replacement_service changes.

  ## Examples

      iex> change_replacement_service(replacement_service)
      %Ecto.Changeset{data: %ReplacementService{}}

  """
  def change_replacement_service(%ReplacementService{} = replacement_service, attrs \\ %{}) do
    ReplacementService.changeset(replacement_service, attrs)
  end
end
