defmodule Arrow.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Arrow.Repo
  use Arrow.OpenRouteServiceFactory

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

  def disruption_v2_factory do
    %Arrow.Disruptions.DisruptionV2{
      title: sequence(:title, &"Disruption #{&1}"),
      mode: :bus,
      is_active: true
    }
  end

  def limit_factory do
    %Arrow.Disruptions.Limit{
      start_date: ~D[2025-01-01],
      end_date: ~D[2025-12-31],
      disruption: build(:disruption_v2),
      route: build(:gtfs_route),
      start_stop: build(:gtfs_stop),
      end_stop: build(:gtfs_stop)
    }
  end

  def limit_day_of_week_factory do
    %Arrow.Limits.LimitDayOfWeek{
      day_name: :monday,
      active?: true,
      limit: build(:limit)
    }
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

  def gtfs_stop_factory(attrs \\ %{}) do
    %Arrow.Gtfs.Stop{
      id: sequence(:source_label, &"gtfs-stop-#{&1}"),
      code: nil,
      name: "Test Stop",
      desc: nil,
      platform_code: nil,
      platform_name: nil,
      lat: 42.3601,
      lon: -71.0589,
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
    |> merge_attributes(attrs)
  end

  def gtfs_route_factory(attrs \\ %{}) do
    %Arrow.Gtfs.Route{
      id: sequence(:source_label, &"gtfs-route-#{&1}"),
      agency: build(:gtfs_agency),
      short_name: nil,
      long_name: "Red Line",
      desc: "Rapid Transit",
      type: :heavy_rail,
      url: "https://www.mbta.com/schedules/Red",
      color: "DA291C",
      text_color: "FFFFFF",
      sort_order: 10_010,
      fare_class: "Rapid Transit",
      listed_route: nil,
      network_id: "rapid_transit"
    }
    |> merge_attributes(attrs)
  end

  def gtfs_agency_factory(attrs \\ %{}) do
    %Arrow.Gtfs.Agency{
      id: sequence(:source_label, &"gtfs-agency-#{&1}"),
      name: "MBTA",
      url: "https://www.mbta.com",
      timezone: "ETC"
    }
    |> merge_attributes(attrs)
  end

  def shuttle_factory do
    %Arrow.Shuttles.Shuttle{
      status: :draft,
      shuttle_name: "Test shuttle",
      disrupted_route_id: "Red"
    }
  end

  def replacement_service_factory(attrs) do
    %Arrow.Disruptions.ReplacementService{
      reason: "Maintenance",
      start_date: Date.utc_today(),
      end_date: Date.utc_today() |> Date.add(6),
      source_workbook_data: build(:replacement_service_workbook_data),
      source_workbook_filename: "file.xlsx",
      disruption: build(:disruption_v2),
      shuttle: build(:shuttle)
    }
    |> merge_attributes(attrs)
  end

  def replacement_service_workbook_data_factory do
    %{
      "WKDY headways and runtimes" => [
        %{
          "end_time" => "06:00",
          "headway" => 10,
          "running_time_0" => 25,
          "running_time_1" => 15,
          "start_time" => "05:00"
        },
        %{
          "end_time" => "07:00",
          "headway" => 15,
          "running_time_0" => 30,
          "running_time_1" => 20,
          "start_time" => "06:00"
        },
        %{"first_trip_0" => "05:10", "first_trip_1" => "05:10"},
        %{"last_trip_0" => "06:30", "last_trip_1" => "06:30"}
      ]
    }
  end
end
