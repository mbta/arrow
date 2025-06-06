defmodule Arrow.Disruptions.LimitTest do
  use Arrow.DataCase

  alias Arrow.Disruptions.Limit

  describe "changeset/2" do
    test "adds errors to child LimitDayOfWeeks that are outside the date range" do
      monday = ~D[2025-05-12]
      thursday = ~D[2025-05-15]

      initial_active_days =
        [
          monday: true,
          tuesday: true,
          wednesday: true,
          thursday: true,
          friday: false,
          saturday: false,
          sunday: false
        ]

      dows =
        Enum.with_index(initial_active_days, fn {day_name, active?}, i ->
          build(:limit_day_of_week, day_name: day_name, active?: active?, id: i)
        end)

      limit = build(:limit, start_date: monday, end_date: thursday, limit_day_of_weeks: dows)

      dow_change_attrs =
        initial_active_days
        |> Keyword.replace!(:friday, true)
        |> Keyword.replace!(:sunday, true)
        # Let's make sure there are no issues with an _inactive_ day within the range.
        |> Keyword.replace!(:tuesday, false)
        |> Enum.with_index(fn {day_name, active?}, i ->
          %{day_name: day_name, active?: active?, id: i}
        end)

      limit_changeset = Limit.changeset(limit, %{limit_day_of_weeks: dow_change_attrs})

      dow_changesets = get_change(limit_changeset, :limit_day_of_weeks)

      expected_error = fn day ->
        day = day |> Atom.to_string() |> String.capitalize()
        {:day_name, {"Dates specified above do not include a #{day}", []}}
      end

      Enum.each(
        [
          tuesday: true,
          friday: false,
          sunday: false
        ],
        fn {day, valid?} ->
          changeset = Enum.find(dow_changesets, &(get_field(&1, :day_name) == day))
          assert changeset.valid? == valid?

          if not valid? do
            assert expected_error.(day) in changeset.errors
          end
        end
      )
    end
  end
end
