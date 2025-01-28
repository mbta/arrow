defmodule ArrowWeb.API.LimitView do
  use ArrowWeb, :html
  use JaSerializer.PhoenixView

  attributes([
    :disruption_id,
    :disruption_name,
    :route_id,
    :start_stop,
    :end_stop,
    :start_date,
    :end_date,
    :days
  ])

  def disruption_name(limit, _conn) do
    limit.disruption.title
  end

  def start_stop(limit, _conn) do
    limit.start_stop.id
  end

  def end_stop(limit, _conn) do
    limit.end_stop.id
  end

  def days(limit, _conn) do
    limit.limit_day_of_weeks
    |> Enum.filter(& &1.active?)
    |> Map.new(fn dow ->
      {dow.day_name,
       %{
         start_time: dow.start_time,
         end_time: dow.end_time,
         is_all_day: is_nil(dow.start_time) and is_nil(dow.end_time)
       }}
    end)
  end
end
