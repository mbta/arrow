# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Arrow.Repo.insert!(%Arrow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Arrow.{Adjustment, AdjustmentFetcher, Disruption, Repo}

:ok = AdjustmentFetcher.fetch()

for {attrs, adjustments} <- [
      {%{
         "exceptions" => [%{excluded_date: ~D[2019-12-29]}],
         "days_of_week" => [
           %{day_name: "friday", start_time: ~T[20:45:00]},
           %{day_name: "saturday"},
           %{day_name: "sunday"}
         ],
         "start_date" => ~D[2019-12-20],
         "end_date" => ~D[2020-01-12]
       }, [Repo.get_by!(Adjustment, source_label: "KenmoreReservoir")]},
      {%{
         "days_of_week" => [
           %{day_name: "monday", start_time: ~T[20:45:00]},
           %{day_name: "tuesday", start_time: ~T[20:45:00]},
           %{day_name: "wednesday", start_time: ~T[20:45:00]},
           %{day_name: "thursday", start_time: ~T[20:45:00]},
           %{day_name: "friday", start_time: ~T[20:45:00]}
         ],
         "start_date" => ~D[2020-01-06],
         "end_date" => ~D[2020-01-17]
       }, [Repo.get_by!(Adjustment, source_label: "KenmoreReservoir")]},
      {%{
         "days_of_week" => [
           %{day_name: "saturday"},
           %{day_name: "sunday"}
         ],
         "start_date" => ~D[2020-01-11],
         "end_date" => ~D[2020-02-09]
       }, [Repo.get_by!(Adjustment, source_label: "AlewifeHarvard")]},
      {%{
         "exceptions" => [
           %{excluded_date: ~D[2019-12-28]},
           %{excluded_date: ~D[2019-12-29]},
           %{excluded_date: ~D[2020-01-04]},
           %{excluded_date: ~D[2020-01-05]}
         ],
         "trip_short_names" => [
           %{trip_short_name: "1702"},
           %{trip_short_name: "1704"},
           %{trip_short_name: "1706"},
           %{trip_short_name: "1708"},
           %{trip_short_name: "1710"},
           %{trip_short_name: "1712"},
           %{trip_short_name: "1714"},
           %{trip_short_name: "2706"},
           %{trip_short_name: "2708"},
           %{trip_short_name: "2710"},
           %{trip_short_name: "2712"},
           %{trip_short_name: "2714"},
           %{trip_short_name: "1703"},
           %{trip_short_name: "1705"},
           %{trip_short_name: "1707"},
           %{trip_short_name: "1709"},
           %{trip_short_name: "1711"},
           %{trip_short_name: "1713"},
           %{trip_short_name: "1715"},
           %{trip_short_name: "1717"},
           %{trip_short_name: "2707"},
           %{trip_short_name: "2709"},
           %{trip_short_name: "2711"},
           %{trip_short_name: "2713"},
           %{trip_short_name: "2715"},
           %{trip_short_name: "2717"}
         ],
         "days_of_week" => [
           %{day_name: "saturday"},
           %{day_name: "sunday"}
         ],
         "start_date" => ~D[2019-12-11],
         "end_date" => ~D[2020-03-29]
       }, [Repo.get_by!(Adjustment, source_label: "ForgeParkReadville")]},
      {%{
         "exceptions" => [
           %{excluded_date: ~D[2019-12-28]},
           %{excluded_date: ~D[2019-12-29]},
           %{excluded_date: ~D[2020-01-04]},
           %{excluded_date: ~D[2020-01-05]}
         ],
         "trip_short_names" => [
           %{trip_short_name: "1716"},
           %{trip_short_name: "1718"},
           %{trip_short_name: "1719"},
           %{trip_short_name: "2716"},
           %{trip_short_name: "2718"},
           %{trip_short_name: "2719"}
         ],
         "days_of_week" => [
           %{day_name: "saturday"},
           %{day_name: "sunday"}
         ],
         "start_date" => ~D[2019-12-11],
         "end_date" => ~D[2020-03-29]
       }, [Repo.get_by!(Adjustment, source_label: "ForgeParkSouthStation")]}
    ] do
  Disruption.create(attrs, adjustments)
end
