defmodule Arrow.DBStructureTest do
  use Arrow.DataCase

  describe "dump_data/1" do
    test "returns complete database structure" do
      adj = insert(:adjustment)

      d = insert(:disruption)

      dr =
        insert(:disruption_revision, %{
          disruption: d,
          start_date: ~D[2020-01-01],
          end_date: ~D[2020-01-15],
          adjustments: [adj],
          days_of_week: [build(:day_of_week, %{day_name: "saturday"})],
          trip_short_names: []
        })

      :ok = Arrow.DisruptionRevision.publish!([dr.id])

      adj_id = adj.id
      dr_id = dr.id
      d_id = d.id
      ddow_id = dr.days_of_week |> Enum.at(0) |> Map.get(:id)
      description = dr.description

      assert %{
               "adjustments" => [
                 %{
                   id: ^adj_id
                 }
               ],
               "disruption_adjustments" => [
                 %{adjustment_id: ^adj_id, disruption_revision_id: ^dr_id, id: _da_id}
               ],
               "disruption_day_of_weeks" => [
                 %{
                   day_name: "saturday",
                   disruption_revision_id: ^dr_id,
                   end_time: nil,
                   id: ^ddow_id,
                   start_time: nil
                 }
               ],
               "disruption_exceptions" => [],
               "disruption_revisions" => [
                 %{
                   disruption_id: ^d_id,
                   end_date: ~D[2020-01-15],
                   description: ^description,
                   id: ^dr_id,
                   is_active: true,
                   start_date: ~D[2020-01-01]
                 }
               ],
               "disruption_trip_short_names" => [],
               "disruptions" => [%{id: ^d_id, published_revision_id: ^dr_id}]
             } = Arrow.DBStructure.dump_data()
    end
  end

  describe "load_data/3" do
    test "load structure into database" do
      data = %{
        "adjustments" => [
          %{
            id: 12_208,
            inserted_at: ~U[2020-09-29 15:17:42.000000Z],
            route_id: "Red",
            source: "gtfs_creator",
            source_label: "Adjustment-0",
            updated_at: ~U[2020-09-29 15:17:42.000000Z]
          }
        ],
        "disruption_adjustments" => [
          %{adjustment_id: 12_208, disruption_revision_id: 11_206, id: 10_729}
        ],
        "disruption_day_of_weeks" => [
          %{
            day_name: "saturday",
            disruption_revision_id: 11_206,
            end_time: nil,
            id: 11_483,
            inserted_at: ~U[2020-09-29 15:17:42.000000Z],
            start_time: nil,
            updated_at: ~U[2020-09-29 15:17:42.000000Z]
          }
        ],
        "disruption_exceptions" => [],
        "disruption_revisions" => [
          %{
            adjustment_kind: nil,
            disruption_id: 8338,
            description: "this is a disruption",
            end_date: ~D[2020-01-15],
            id: 11_206,
            inserted_at: ~U[2020-09-29 15:17:42.000000Z],
            is_active: true,
            start_date: ~D[2020-01-01],
            updated_at: ~U[2020-09-29 15:17:42.000000Z],
            row_approved: true
          }
        ],
        "disruption_trip_short_names" => [],
        "disruptions" => [
          %{
            id: 8338,
            inserted_at: ~U[2020-09-29 15:17:42.000000Z],
            published_revision_id: 11_206,
            updated_at: ~U[2020-09-29 15:17:42.000000Z],
            last_published_at: nil
          }
        ]
      }

      :ok = Arrow.DBStructure.load_data(Arrow.Repo, data)

      assert data == Arrow.DBStructure.dump_data()
    end
  end
end
