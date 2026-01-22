defmodule Arrow.Integration.Disruptionsv2.TrainsformerExportSectionTest do
  use ExUnit.Case
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.DisruptionsFixtures
  import Arrow.Factory

  @moduletag :integration

  setup do
    stops = [
      "NEC-2287",
      "NEC-2276-01",
      "FB-0118-01",
      "FS-0049-S",
      "NEC-1851-03",
      "NEC-1891-02",
      "NEC-1969-04",
      "NEC-2040-01",
      "BNT-0000",
      "WR-0045-S"
    ]

    for stop <- stops do
      insert(:gtfs_stop, id: stop, name: stop, lat: 0, lon: 0, municipality: "Boston")
    end

    :ok
  end

  feature "can upload a Trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/valid_export.zip"
    )
    |> assert_text("Successfully imported export valid_export.zip!")
    |> click(Query.css("#save-export-button"))
    |> assert_text("CR-Foxboro")
    |> assert_text("SPRING2025-SOUTHSS-Weekend-66")
    |> assert_text("Timetable")
  end

  feature "reports invalid ZIP errors", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_zip.zip"
    )
    |> assert_text("Invalid zip file")
  end

  feature "shows error for invalid gtfs stops in trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_stops_missing_from_gtfs.zip"
    )
    |> assert_text("Some stops are not present in GTFS!")
  end

  feature "shows error for previously used service_ids in export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})
    disruption2 = disruption_v2_fixture(%{mode: :commuter_rail})

    session =
      session
      |> visit("/disruptions/#{disruption.id}")
      |> click(text("Upload Trainsformer export"))
      |> assert_text("Upload Trainsformer .zip")
      |> attach_file(file_field("trainsformer_export", visible: false),
        path: "test/support/fixtures/trainsformer/valid_export.zip"
      )
      |> click(Query.css("#save-export-button"))

    # new disruption
    session
    |> visit("/disruptions/#{disruption2.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/valid_export.zip"
    )
    |> assert_text("Export contains previously used service ids")
  end

  feature "shows error for invalid stop order in trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_stop_times_out_of_order.zip"
    )
    |> assert_text("Some stop times are out of order!")
  end

  feature "shows warning for trainsformer export containing North and South Station", %{
    session: session
  } do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_north_and_south_station.zip"
    )
    |> assert_text("Warning: export contains trips serving North and South Station.")
  end

  feature "shows warning for trainsformer export containing neither North nor South Station", %{
    session: session
  } do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path:
        "test/support/fixtures/trainsformer/invalid_export_neither_north_nor_south_station.zip"
    )
    |> assert_text("Warning: export does not contain trips serving North or South Station.")
  end

  feature "shows warning for trainsformer export containing some but not all routes for a side",
          %{
            session: session
          } do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_missing_south_side_routes.zip"
    )
    |> assert_text("Warning: Not all northside or southside routes are present. Missing routes:")
  end

  feature "shows warning for trainsformer export containing multiple routes that are neither north nor southside",
          %{
            session: session
          } do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_multiple_no_side_routes.zip"
    )
    |> assert_text("Warning: multiple routes not north or southside:")
  end

  feature "shows warning for missing transfers in trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> assert_text("Upload Trainsformer .zip")
    |> attach_file(file_field("trainsformer_export", visible: false),
      path: "test/support/fixtures/trainsformer/invalid_export_missing_transfers.zip"
    )
    |> assert_text(
      "Warning: some train trips that do not serve North Station, South Station, or Foxboro lack transfers."
    )
  end

  feature "can cancel uploading a Trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session
    |> visit("/disruptions/#{disruption.id}")
    |> click(text("Upload Trainsformer export"))
    |> click(text("Cancel"))
    |> assert_text("Upload Trainsformer export")
  end

  feature "can cancel saving an uploaded Trainsformer export", %{session: session} do
    disruption = disruption_v2_fixture(%{mode: :commuter_rail})

    session =
      session
      |> visit("/disruptions/#{disruption.id}")
      |> click(text("Upload Trainsformer export"))
      |> assert_text("Upload Trainsformer .zip")
      |> attach_file(file_field("trainsformer_export", visible: false),
        path: "test/support/fixtures/trainsformer/valid_export.zip"
      )
      |> assert_text("Successfully imported export valid_export.zip!")

    accept_prompt(session, fn s ->
      s |> click(text("Cancel")) |> assert_text("Upload Trainsformer export")
    end)
  end
end
