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
      trip_short_names: [build(:trip_short_name)]
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
end
