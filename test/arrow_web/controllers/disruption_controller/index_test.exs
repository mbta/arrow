defmodule ArrowWeb.DisruptionController.IndexTest do
  use Arrow.DataCase, async: true
  import Arrow.Factory

  alias ArrowWeb.DisruptionController.{Filters, Index}
  alias ArrowWeb.DisruptionController.Filters.Table

  describe "all/0" do
    test "gets disruptions whose latest revision is active" do
      [%{id: active_id} = d1, d2] = insert_list(2, :disruption)
      insert_list(2, :disruption_revision, disruption: d1)
      insert(:disruption_revision, disruption: d2, is_active: true)
      insert(:disruption_revision, disruption: d2, is_active: false)

      assert [%{id: ^active_id}] = Index.all()
    end

    test "preloads the latest revisions of disruptions and their associations" do
      %{id: disruption_id} = disruption = insert(:disruption)
      insert(:disruption_revision, disruption: disruption)

      %{id: latest_revision_id} =
        insert(:disruption_revision,
          disruption: disruption,
          adjustments: [build(:adjustment, source_label: "TestAdj")],
          days_of_week: [build(:day_of_week, day_name: "monday")],
          exceptions: [build(:exception, excluded_date: ~D[2021-01-01])]
        )

      assert [
               %{
                 id: ^disruption_id,
                 revisions: [
                   %{
                     id: ^latest_revision_id,
                     adjustments: [%{source_label: "TestAdj"}],
                     days_of_week: [%{day_name: "monday"}],
                     exceptions: [%{excluded_date: ~D[2021-01-01]}]
                   }
                 ]
               }
             ] = Index.all()
    end

    test "sorts preloaded adjustments by label" do
      insert(:disruption_revision,
        adjustments: [
          build(:adjustment, source_label: "Second"),
          build(:adjustment, source_label: "First"),
          build(:adjustment, source_label: "Third")
        ]
      )

      assert [
               %{
                 revisions: [
                   %{
                     adjustments: [
                       %{source_label: "First"},
                       %{source_label: "Second"},
                       %{source_label: "Third"}
                     ]
                   }
                 ]
               }
             ] = Index.all()
    end

    test "includes disruptions with no adjustments" do
      %{disruption_id: id} = insert(:disruption_revision, adjustments: [])

      assert [%{id: ^id}] = Index.all()
    end
  end

  describe "all/1" do
    defp filters(attrs) do
      # Undo the default date filter and sort by ID for consistent ordering
      struct(%Filters{view: struct(%Table{include_past?: true, sort: {:asc, :id}}, attrs)}, attrs)
    end

    defp filtered(attrs), do: attrs |> filters() |> Index.all()

    test "filters out disruptions that ended more than a week ago" do
      today = Date.utc_today()
      %{disruption_id: new_id} = insert(:disruption_revision, end_date: today)
      %{disruption_id: old_id} = insert(:disruption_revision, end_date: Date.add(today, -8))

      assert [%{id: ^new_id}] = filtered(include_past?: false)
      assert [%{id: ^new_id}, %{id: ^old_id}] = filtered(include_past?: true)
    end

    test "filters by a case-insensitive search term in descriptions and adjustment labels" do
      adj1 = build(:adjustment, source_label: "TrackChange")
      %{disruption_id: id1} = insert(:disruption_revision, adjustments: [adj1])
      adj2 = build(:adjustment, source_label: "StationClosed")
      insert(:disruption_revision, adjustments: [adj2])
      %{disruption_id: id2} = insert(:disruption_revision, description: "Track change")
      insert(:disruption_revision, description: "Station closed")

      assert [%{id: ^id1}, %{id: ^id2}] = filtered(search: "track")
    end

    test "filters by kind with existing adjustments" do
      red = insert(:adjustment, route_id: "Red")
      blue = insert(:adjustment, route_id: "Blue")
      orange = insert(:adjustment, route_id: "Orange")
      %{disruption_id: id1} = insert(:disruption_revision, adjustments: [red, blue])
      %{disruption_id: id2} = insert(:disruption_revision, adjustments: [orange])
      insert(:disruption_revision, adjustments: [red])

      assert [%{id: ^id1}, %{id: ^id2}] = filtered(kinds: MapSet.new(~w(blue_line orange_line)a))
    end

    test "filters by kind using the adjustment_kind of disruptions" do
      %{disruption_id: id} = insert(:disruption_revision, adjustment_kind: :red_line)

      insert(:disruption_revision, adjustment_kind: :blue_line)

      assert [%{id: ^id}] = filtered(kinds: MapSet.new(~w(red_line)a))
    end

    test "filters by kind using all Green Line routes for green_line" do
      glb = insert(:adjustment, route_id: "Green-B")
      gld = insert(:adjustment, route_id: "Green-D")
      %{disruption_id: id1} = insert(:disruption_revision, adjustments: [glb])
      %{disruption_id: id2} = insert(:disruption_revision, adjustments: [gld])
      %{disruption_id: id3} = insert(:disruption_revision, adjustment_kind: :green_line)
      %{disruption_id: id4} = insert(:disruption_revision, adjustment_kind: :green_line_c)

      insert(:disruption_revision, adjustment_kind: :red_line, adjustments: [])

      assert [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}, %{id: ^id4}] =
               filtered(kinds: MapSet.new(~w(green_line)a))
    end

    test "sorts by disruption ID" do
      %{disruption_id: id1} = insert(:disruption_revision)
      %{disruption_id: id2} = insert(:disruption_revision)

      assert [%{id: ^id1}, %{id: ^id2}] = filtered(sort: {:asc, :id})
      assert [%{id: ^id2}, %{id: ^id1}] = filtered(sort: {:desc, :id})
    end

    test "sorts by disruption start date" do
      %{disruption_id: id2} = insert(:disruption_revision, start_date: ~D[2021-01-02])
      %{disruption_id: id1} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      %{disruption_id: id3} = insert(:disruption_revision, start_date: ~D[2021-01-03])

      assert [%{id: ^id1}, %{id: ^id2}, %{id: ^id3}] = filtered(sort: {:asc, :start_date})
    end
  end
end
