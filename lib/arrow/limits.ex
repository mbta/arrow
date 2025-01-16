defmodule Arrow.Limits do
  @moduledoc """
  The Limits context.
  """

  alias Arrow.Repo
  alias Arrow.Disruptions.Limit

  @preloads [:route, :start_stop, :end_stop, :limit_day_of_weeks]

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

  alias Arrow.Limits.LimitDayOfWeek

  @doc """
  Returns the list of limit_day_of_weeks.

  ## Examples

      iex> list_limit_day_of_weeks()
      [%LimitDayOfWeek{}, ...]

  """
  def list_limit_day_of_weeks do
    Repo.all(LimitDayOfWeek)
  end

  @doc """
  Gets a single limit_day_of_week.

  Raises `Ecto.NoResultsError` if the Limit day of week does not exist.

  ## Examples

      iex> get_limit_day_of_week!(123)
      %LimitDayOfWeek{}

      iex> get_limit_day_of_week!(456)
      ** (Ecto.NoResultsError)

  """
  def get_limit_day_of_week!(id), do: Repo.get!(LimitDayOfWeek, id)

  @doc """
  Creates a limit_day_of_week.

  ## Examples

      iex> create_limit_day_of_week(%{field: value})
      {:ok, %LimitDayOfWeek{}}

      iex> create_limit_day_of_week(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_limit_day_of_week(attrs \\ %{}) do
    %LimitDayOfWeek{}
    |> LimitDayOfWeek.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a limit_day_of_week.

  ## Examples

      iex> update_limit_day_of_week(limit_day_of_week, %{field: new_value})
      {:ok, %LimitDayOfWeek{}}

      iex> update_limit_day_of_week(limit_day_of_week, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_limit_day_of_week(%LimitDayOfWeek{} = limit_day_of_week, attrs) do
    limit_day_of_week
    |> LimitDayOfWeek.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a limit_day_of_week.

  ## Examples

      iex> delete_limit_day_of_week(limit_day_of_week)
      {:ok, %LimitDayOfWeek{}}

      iex> delete_limit_day_of_week(limit_day_of_week)
      {:error, %Ecto.Changeset{}}

  """
  def delete_limit_day_of_week(%LimitDayOfWeek{} = limit_day_of_week) do
    Repo.delete(limit_day_of_week)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking limit_day_of_week changes.

  ## Examples

      iex> change_limit_day_of_week(limit_day_of_week)
      %Ecto.Changeset{data: %LimitDayOfWeek{}}

  """
  def change_limit_day_of_week(%LimitDayOfWeek{} = limit_day_of_week, attrs \\ %{}) do
    LimitDayOfWeek.changeset(limit_day_of_week, attrs)
  end
end
