defmodule Arrow.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Arrow.Repo

  def adjustment_factory do
    %Arrow.Adjustment{
      route_id: "Red",
      source: "gtfs_creator",
      source_label: sequence(:source_label, &"Adjustment-#{&1}")
    }
  end

  def disruption_factory do
    %Arrow.Disruption{
      published_revision: nil
    }
  end

  def disruption_revision_factory(attrs) do
    %Arrow.DisruptionRevision{
      start_date: Date.utc_today(),
      end_date: Date.utc_today() |> Date.add(6),
      description: sequence("Description"),
      adjustment_kind: :bus,
      disruption: build(:disruption),
      days_of_week: [build(:day_of_week)],
      trip_short_names: [build(:trip_short_name)],
      title: sequence("Title")
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
    |> then(fn
      # Prevent setting both an adjustment kind and non-empty adjustments
      %{adjustments: [_ | _]} = revision -> %{revision | adjustment_kind: nil}
      revision -> revision
    end)
  end

  def day_of_week_factory do
    %Arrow.Disruption.DayOfWeek{
      day_name: "saturday",
      start_time: nil,
      end_time: nil
    }
  end

  def exception_factory do
    %Arrow.Disruption.Exception{excluded_date: ~D[2020-01-10]}
  end

  def trip_short_name_factory do
    %Arrow.Disruption.TripShortName{trip_short_name: "1234"}
  end

  def note_factory do
    %Arrow.Disruption.Note{author: "An author", body: "This is the body."}
  end

  def route_stop_factory do
    %Arrow.Shuttles.RouteStop{
      direction_id: :"0",
      stop_sequence: sequence(:route_stop_stop_sequence, & &1)
    }
  end

  def stop_factory do
    %Arrow.Shuttles.Stop{
      stop_id: sequence(:source_label, &"stop-#{&1}"),
      stop_name: sequence(:source_label, &"Stop #{&1}"),
      stop_desc: sequence(:source_label, &"Stop Description #{&1}"),
      stop_lat: 72.0,
      stop_lon: 43.0,
      municipality: "Boston"
    }
  end

  def gtfs_stop_factory do
    %Arrow.Gtfs.Stop{
      id: sequence(:source_label, &"gtfs-stop-#{&1}"),
      code: nil,
      name: "Test Stop",
      desc: nil,
      platform_code: nil,
      platform_name: nil,
      lat: 72.0,
      lon: 43.0,
      zone_id: nil,
      address: nil,
      url: nil,
      level: nil,
      location_type: :stop_platform,
      parent_station: nil,
      wheelchair_boarding: :accessible,
      municipality: "Boston",
      on_street: nil,
      at_street: nil,
      vehicle_type: :bus
    }
  end
end
