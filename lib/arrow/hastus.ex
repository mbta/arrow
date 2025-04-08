defmodule Arrow.Hastus do
  @moduledoc """
  The Hastus context.
  """

  import Ecto.Query, warn: false

  alias Arrow.Repo

  @preloads [
    :line,
    :disruption,
    :trip_route_directions,
    services: [:service_dates, :start_stop, :end_stop]
  ]

  alias Arrow.Hastus.Export

  @doc """
  Returns the list of exports.

  ## Examples

      iex> list_exports()
      [%Export{}, ...]

  """
  def list_exports do
    Export |> Repo.all() |> Repo.preload(@preloads)
  end

  @doc """
  Gets a single export.

  Raises `Ecto.NoResultsError` if the Export does not exist.

  ## Examples

      iex> get_export!(123)
      %Export{}

      iex> get_export!(456)
      ** (Ecto.NoResultsError)

  """
  def get_export!(id), do: Export |> Repo.get!(id) |> Repo.preload(@preloads)

  @doc """
  Creates a export.

  ## Examples

      iex> create_export(%{field: value})
      {:ok, %Export{}}

      iex> create_export(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_export(attrs \\ %{}) do
    %Export{}
    |> Export.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a export.

  ## Examples

      iex> update_export(export, %{field: new_value})
      {:ok, %Export{}}

      iex> update_export(export, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_export(%Export{} = export, attrs) do
    export
    |> Export.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a export.

  ## Examples

      iex> delete_export(export)
      {:ok, %Export{}}

      iex> delete_export(export)
      {:error, %Ecto.Changeset{}}

  """
  def delete_export(%Export{} = export) do
    Repo.delete(export)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking export changes.

  ## Examples

      iex> change_export(export)
      %Ecto.Changeset{data: %Export{}}

  """
  def change_export(%Export{} = export, attrs \\ %{}) do
    Export.changeset(export, attrs)
  end

  alias Arrow.Hastus.Service

  @doc """
  Returns the list of hastus_services.

  ## Examples

      iex> list_hastus_services()
      [%Service{}, ...]

  """
  def list_hastus_services do
    Repo.all(Service)
  end

  @doc """
  Gets a single service.

  Raises `Ecto.NoResultsError` if the Service does not exist.

  ## Examples

      iex> get_service!(123)
      %Service{}

      iex> get_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service!(id), do: Repo.get!(Service, id)

  @doc """
  Creates a service.

  ## Examples

      iex> create_service(%{field: value})
      {:ok, %Service{}}

      iex> create_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service(attrs \\ %{}) do
    %Service{}
    |> Service.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service.

  ## Examples

      iex> update_service(service, %{field: new_value})
      {:ok, %Service{}}

      iex> update_service(service, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service(%Service{} = service, attrs) do
    service
    |> Service.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a service.

  ## Examples

      iex> delete_service(service)
      {:ok, %Service{}}

      iex> delete_service(service)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service(%Service{} = service) do
    Repo.delete(service)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service changes.

  ## Examples

      iex> change_service(service)
      %Ecto.Changeset{data: %Service{}}

  """
  def change_service(%Service{} = service, attrs \\ %{}) do
    Service.changeset(service, attrs)
  end

  alias Arrow.Hastus.ServiceDate

  @doc """
  Returns the list of hastus_service_dates.

  ## Examples

      iex> list_hastus_service_dates()
      [%ServiceDate{}, ...]

  """
  def list_hastus_service_dates do
    Repo.all(ServiceDate)
  end

  @doc """
  Gets a single service_date.

  Raises `Ecto.NoResultsError` if the Service date does not exist.

  ## Examples

      iex> get_service_date!(123)
      %ServiceDate{}

      iex> get_service_date!(456)
      ** (Ecto.NoResultsError)

  """
  def get_service_date!(id), do: Repo.get!(ServiceDate, id)

  @doc """
  Creates a service_date.

  ## Examples

      iex> create_service_date(%{field: value})
      {:ok, %ServiceDate{}}

      iex> create_service_date(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_service_date(attrs \\ %{}) do
    %ServiceDate{}
    |> ServiceDate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a service_date.

  ## Examples

      iex> update_service_date(service_date, %{field: new_value})
      {:ok, %ServiceDate{}}

      iex> update_service_date(service_date, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_service_date(%ServiceDate{} = service_date, attrs) do
    service_date
    |> ServiceDate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a service_date.

  ## Examples

      iex> delete_service_date(service_date)
      {:ok, %ServiceDate{}}

      iex> delete_service_date(service_date)
      {:error, %Ecto.Changeset{}}

  """
  def delete_service_date(%ServiceDate{} = service_date) do
    Repo.delete(service_date)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking service_date changes.

  ## Examples

      iex> change_service_date(service_date)
      %Ecto.Changeset{data: %ServiceDate{}}

  """
  def change_service_date(%ServiceDate{} = service_date, attrs \\ %{}) do
    ServiceDate.changeset(service_date, attrs)
  end

  @doc """
  Returns `Arrow.Hastus.Export`s with an active disruption and service dates
  within `:start_date` and `:end_date`.
  """
  def list_service_schedules(opts) do
    start_date = Keyword.fetch!(opts, :start_date)
    end_date = Keyword.fetch!(opts, :end_date)

    query =
      from exports in Export,
        join: disruptions in assoc(exports, :disruption),
        left_join: trip_route_directions in assoc(exports, :trip_route_directions),
        join: services in assoc(exports, :services),
        join: service_dates in assoc(services, :service_dates),
        where: disruptions.is_active == true,
        where:
          fragment(
            "daterange(?, ?, '[]') && daterange(?, ?, '[]')",
            service_dates.start_date,
            service_dates.end_date,
            ^start_date,
            ^end_date
          ),
        preload: [
          disruption: disruptions,
          trip_route_directions: trip_route_directions,
          services: {services, service_dates: service_dates}
        ]

    Repo.all(query)
  end

  def export_download_url(%Export{s3_path: "s3://" <> s3_path}) do
    [bucket, path] = String.split(s3_path, "/", parts: 2)

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket, path)
  end
end
