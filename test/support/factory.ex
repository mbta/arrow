defmodule Arrow.Factory do
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

  def disruption_revision_factory do
    %Arrow.DisruptionRevision{
      start_date: ~D[2020-01-01],
      end_date: ~D[2020-01-15],
      disruption: [build(:disruption)],
      days_of_week: [build(:day_of_week)],
      adjustments: [build(:adjustment)],
      trip_short_names: [build(:trip_short_name)]
    }
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
end
