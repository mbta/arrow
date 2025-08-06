defmodule Arrow.Disruptions do
  @moduledoc """
  The Disruptions context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Disruptions.Limit
  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Shuttles

  @preloads [
    limits: [:route, :start_stop, :end_stop, :limit_day_of_weeks],
    replacement_services: [shuttle: [routes: [route_stops: [:stop]]]],
    hastus_exports: [:line, services: [:service_dates, derived_limits: [:start_stop, :end_stop]]]
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
    disruption_v2 =
      %DisruptionV2{}
      |> DisruptionV2.changeset(attrs)
      |> Repo.insert()

    case disruption_v2 do
      {:ok, disruption_v2} -> {:ok, disruption_v2 |> Repo.preload(@preloads)}
      err -> err
    end
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
    update_disruption_v2 =
      disruption_v2
      |> DisruptionV2.changeset(attrs)
      |> Repo.update()

    case update_disruption_v2 do
      {:ok, disruption_v2} -> {:ok, disruption_v2 |> Repo.preload(@preloads)}
      err -> err
    end
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

  @doc """
  Gets a single replacement_service.

  Raises `Ecto.NoResultsError` if the Replacement service does not exist.

  ## Examples

      iex> get_replacement_service!(123)
      %ReplacementService{}

      iex> get_replacement_service!(456)
      ** (Ecto.NoResultsError)

  """
  def get_replacement_service!(id),
    do: Repo.get!(ReplacementService, id) |> Repo.preload(@preloads[:replacement_services])

  @doc """
  Creates a replacement_service.

  ## Examples

      iex> create_replacement_service(%{field: value})
      {:ok, %ReplacementService{}}

      iex> create_replacement_service(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_replacement_service(attrs \\ %{}) do
    create_replacement_service =
      %ReplacementService{}
      |> ReplacementService.changeset(attrs)
      |> Repo.insert()

    case create_replacement_service do
      {:ok, rs} -> {:ok, rs |> Repo.preload(@preloads[:replacement_services])}
      err -> err
    end
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
    update_replacement_service =
      replacement_service
      |> ReplacementService.changeset(attrs)
      |> Repo.update()

    case update_replacement_service do
      {:ok, rs} -> {:ok, rs |> Repo.preload(@preloads[:replacement_services])}
      err -> err
    end
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

  @doc """
  Returns all active limits that overlap with the given date range.

  ## Examples

      iex> get_limits_in_date_range(~D[2025-06-01], ~D[2025-06-30])
      [%Limit{}, ...]

  """
  def get_limits_in_date_range(start_date, end_date) do
    from(l in Limit,
      join: d in assoc(l, :disruption),
      where: d.is_active == true,
      where: l.start_date <= ^end_date and l.end_date >= ^start_date,
      preload: [
        :disruption,
        :route,
        :start_stop,
        :end_stop,
        limit_day_of_weeks: :limit
      ]
    )
    |> Repo.all()
  end

  @spec replacement_service_trips_with_times(ReplacementService.t(), String.t()) :: map()
  def replacement_service_trips_with_times(
        %ReplacementService{source_workbook_data: source_workbook_data, shuttle: shuttle},
        day_of_week
      ) do
    day_of_week_data = source_workbook_data["#{day_of_week} headways and runtimes"]

    {first_trips, last_trips, headway_periods} =
      Enum.reduce(day_of_week_data, {%{}, %{}, %{}}, fn data,
                                                        {first_trips, last_trips, headway_periods} ->
        case data do
          %{"first_trip_0" => first_trip_0, "first_trip_1" => first_trip_1} ->
            {%{0 => first_trip_0, 1 => first_trip_1}, last_trips, headway_periods}

          %{"last_trip_0" => last_trip_0, "last_trip_1" => last_trip_1} ->
            {first_trips, %{0 => last_trip_0, 1 => last_trip_1}, headway_periods}

          %{"start_time" => start_time} = headway_period ->
            {first_trips, last_trips, Map.put(headway_periods, start_time, headway_period)}
        end
      end)

    [direction_0_trips, direction_1_trips] =
      for direction_id <- [0, 1] do
        start_times =
          do_make_trip_start_times(
            first_trips[direction_id],
            last_trips[direction_id],
            [],
            headway_periods
          )

        shuttle_route =
          Enum.find(
            shuttle.routes,
            &(&1.direction_id == direction_id |> Integer.to_string() |> String.to_existing_atom())
          )

        Enum.map(
          start_times,
          &build_stop_times_for_start_time(&1, direction_id, headway_periods, shuttle_route)
        )
      end

    %{"0" => direction_0_trips, "1" => direction_1_trips}
  end

  @spec build_stop_times_for_start_time(String.t(), String.t(), map(), Shuttles.Route.t()) ::
          map()
  defp build_stop_times_for_start_time(start_time, direction_id, headway_periods, shuttle_route) do
    total_runtime =
      headway_periods
      |> Map.get(start_of_hour(start_time))
      |> Map.get("running_time_#{direction_id}")

    total_times_to_next_stop =
      Enum.reduce(shuttle_route.route_stops, 0, fn route_stop, acc ->
        if is_nil(route_stop.time_to_next_stop) do
          acc
        else
          acc + Decimal.to_float(route_stop.time_to_next_stop)
        end
      end)

    {_, stop_times} =
      Enum.reduce(shuttle_route.route_stops, {start_time, []}, fn route_stop,
                                                                  {current_stop_time, stop_times} ->
        {if is_nil(route_stop.time_to_next_stop) do
           current_stop_time
         else
           time_to_next_stop = Decimal.to_float(route_stop.time_to_next_stop)

           add_minutes(
             current_stop_time,
             round(time_to_next_stop / total_times_to_next_stop * total_runtime)
           )
         end,
         stop_times ++
           [
             %{
               stop_id: Shuttles.get_display_stop_id(route_stop),
               stop_time: current_stop_time
             }
           ]}
      end)

    %{
      stop_times: stop_times
    }
  end

  defp do_make_trip_start_times(
         first_trip_start_time,
         last_trip_start_time,
         trip_start_times,
         _headway_periods
       )
       when first_trip_start_time > last_trip_start_time,
       do: trip_start_times

  defp do_make_trip_start_times(
         first_trip_start_time,
         last_trip_start_time,
         trip_start_times,
         headway_periods
       ) do
    headway =
      headway_periods |> Map.get(start_of_hour(first_trip_start_time)) |> Map.get("headway")

    first_trip_start_time
    |> add_minutes(headway)
    |> do_make_trip_start_times(
      last_trip_start_time,
      trip_start_times ++ [first_trip_start_time],
      headway_periods
    )
  end

  defp start_of_hour(gtfs_time_string) do
    String.slice(gtfs_time_string, 0..1) <> ":00"
  end

  defp add_minutes(gtfs_time_string, minutes_to_add) do
    [hours, minutes] = gtfs_time_string |> String.split(":") |> Enum.map(&String.to_integer/1)

    final_minutes = round(hours * 60 + minutes + minutes_to_add)

    result_hours = div(final_minutes, 60)
    result_minutes = rem(final_minutes, 60)

    Enum.map_join(
      [result_hours, result_minutes],
      ":",
      &(&1 |> Integer.to_string() |> String.pad_leading(2, "0"))
    )
  end

  def start_end_dates(%DisruptionV2{
        limits: limits,
        replacement_services: replacement_services,
        hastus_exports: hastus_exports
      }) do
    hastus_service_dates =
      Enum.flat_map(hastus_exports, fn export ->
        export.services
        |> Enum.filter(& &1.import?)
        |> Enum.flat_map(& &1.service_dates)
      end)

    if limits == [] and replacement_services == [] and hastus_service_dates == [] do
      {nil, nil}
    else
      min_date =
        (limits ++ replacement_services ++ hastus_service_dates)
        |> Enum.map(& &1.start_date)
        |> Enum.min(Date, fn -> ~D[9999-12-31] end)

      max_date =
        (limits ++ replacement_services ++ hastus_service_dates)
        |> Enum.map(& &1.end_date)
        |> Enum.max(Date, fn -> ~D[0000-01-01] end)

      {min_date, max_date}
    end
  end
end
