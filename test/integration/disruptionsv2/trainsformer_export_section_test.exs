defmodule Arrow.Integration.Disruptionsv2.TrainsformerExportSectionTest do
  use ExUnit.Case
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.DisruptionsFixtures

  @moduletag :integration

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
    |> assert_text("Export information goes here")
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
