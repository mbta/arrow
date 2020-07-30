defmodule Test.Support.Helpers do
  defmacro reassign_env(var, value) do
    quote do
      old_value = Application.get_env(:arrow, unquote(var))
      Application.put_env(:arrow, unquote(var), unquote(value))

      on_exit(fn ->
        Application.put_env(:arrow, unquote(var), old_value)
      end)
    end
  end

  alias Arrow.{Disruption, Repo, Adjustment}
  alias Arrow.Disruption.DayOfWeek

  def future_date() do
    {:ok, now} = DateTime.now(Application.get_env(:arrow, :time_zone))
    today = DateTime.to_date(now)
    Date.add(today, 10)
  end

  def past_date() do
    {:ok, now} = DateTime.now(Application.get_env(:arrow, :time_zone))
    today = DateTime.to_date(now)
    Date.add(today, -10)
  end

  def insert_adjustment(opts) do
    source_label = Keyword.get(opts, :source_label)
    route_id = Keyword.get(opts, :route_id)
    source = Keyword.get(opts, :source)

    Repo.insert!(
      Adjustment.changeset(%Adjustment{}, %{
        source: source,
        source_label: source_label,
        route_id: route_id
      })
    )
  end

  def insert_disruption(opts) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    exceptions =
      opts
      |> Keyword.get(:exceptions, [])
      |> Enum.map(&%{"excluded_date" => &1})

    trip_short_names =
      opts
      |> Keyword.get(:trip_short_names, [])
      |> Enum.map(&%{"trip_short_name" => &1})

    days_of_week =
      opts
      |> Keyword.get(:days_of_week, [])
      |> Enum.map(
        &%{
          day_name: Map.get(&1, :day_name),
          start_time: Map.get(&1, :start_time),
          end_time: Map.get(&1, :end_time)
        }
      )

    adjustments = Keyword.get(opts, :adjustments, [])
    current_time = Keyword.get(opts, :current_time)

    Repo.insert!(
      Disruption.changeset_for_create(
        %Disruption{},
        %{
          "start_date" => start_date,
          "end_date" => end_date,
          "exceptions" => exceptions,
          "trip_short_names" => trip_short_names,
          "days_of_week" => days_of_week
        },
        adjustments,
        current_time
      )
    )
  end

  def insert_disruptions(current_time) do
    adjustment_1 =
      insert_adjustment(
        source_label: "test_adjustment_1",
        route_id: "test_route_1",
        source: "arrow"
      )

    disruption_1 =
      insert_disruption(
        start_date: ~D[2019-10-10],
        end_date: future_date(),
        days_of_week: [
          %{day_name: DayOfWeek.date_to_day_name(future_date()), start_time: ~T[20:30:00]}
        ],
        exceptions: [future_date()],
        trip_short_names: ["006"],
        adjustments: [adjustment_1],
        current_time: current_time
      )

    adjustment_2 =
      insert_adjustment(
        source_label: "test_adjustment_2",
        route_id: "test_route_2",
        source: "gtfs_creator"
      )

    disruption_2 =
      insert_disruption(
        start_date: ~D[2019-11-15],
        end_date: Date.add(future_date(), 5),
        days_of_week: [%{day_name: "friday", start_time: ~T[20:30:00]}],
        adjustments: [adjustment_2],
        current_time: current_time
      )

    {disruption_1, disruption_2}
  end
end
