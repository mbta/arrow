defmodule Arrow.Integration.DisruptionsTest do
  use ExUnit.Case, async: true
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.Factory
  import Ecto.Query, only: [from: 2]

  @moduletag :integration

  feature "can view disruption on home page", %{session: session} do
    disruption = insert(:disruption_revision)
    start_date = Calendar.strftime(disruption.start_date, "%m/%d/%Y")
    end_date = Calendar.strftime(disruption.start_date, "%m/%d/%Y")

    session
    |> visit("/")
    |> assert_text(disruption.description)
    |> assert_text(start_date)
    |> assert_text(end_date)
    |> assert_text("Start of service – End of service")
  end

  feature "can create a disruption", %{session: session} do
    adjustment = insert(:adjustment, route_id: "Green-B", source_label: "KendallPackardsCorner")
    now = DateTime.now!("America/New_York")

    [date, day] =
      now
      |> Calendar.strftime("%m/%d/%Y %a")
      |> String.split()

    disruption_id =
      session
      |> visit("/")
      |> click(link("create new"))
      |> assert_text("create new disruption")
      |> click(text("Pending"))
      |> click(text("Subway"))
      |> fill_in(css("[aria-label='description']"), with: "a test description")
      |> click(text("Select..."))
      |> click(text("Kendall Packards Corner"))
      |> fill_in(text_field("start"), with: date)
      |> send_keys([:enter])
      |> fill_in(text_field("end"), with: date)
      |> send_keys([:enter])
      |> click(css("label", text: day))
      |> assert_text("Start of service")
      |> click(button("save"))
      |> assert_text("created successfully")
      |> Browser.text(css("h5 span"))
      |> String.to_integer()

    revision =
      Arrow.Repo.one!(
        from d in Arrow.DisruptionRevision,
          preload: [:days_of_week, :adjustments],
          where: d.disruption_id == ^disruption_id
      )

    assert revision.start_date == now |> DateTime.to_date()
    assert revision.end_date == now |> DateTime.to_date()
    assert revision.row_approved == false
    assert revision.description == "a test description"
    assert Enum.count(revision.days_of_week) == 1
    revision_day = Enum.at(revision.days_of_week, 0)

    assert revision_day.day_name ==
             now |> Calendar.strftime("%A") |> String.downcase()

    assert revision_day.start_time == ~T[20:45:00]
    assert revision_day.end_time == nil
    assert Enum.at(revision.adjustments, 0).source_label == adjustment.source_label
  end

  feature "can update a disruption", %{session: session} do
    revision = insert(build_today_revision())
    original_adjustment = Enum.at(revision.adjustments, 0)

    added_adjustment =
      insert(:adjustment, route_id: "Green-B", source_label: "KendallPackardsCorner")

    id = revision.disruption_id
    description = revision.description
    now = DateTime.now!("America/New_York")

    disruption_id =
      session
      |> visit("/")
      |> click(link(id))
      |> assert_text(description)
      |> assert_text(Calendar.strftime(revision.start_date, "%m/%d/%Y"))
      |> assert_text(Calendar.strftime(revision.end_date, "%m/%d/%Y"))
      |> click(link("edit"))
      |> assert_text("edit disruption")
      |> assert_text(description)
      |> fill_in(css("[aria-label='description']"), with: "an updated description")
      |> send_keys([:tab])
      |> send_keys([:tab])
      |> send_keys([:down_arrow])
      |> click(text("Kendall Packards Corner"))
      |> click(button("save"))
      |> click(link("edit"))
      |> assert_text("an updated description")
      |> assert_text("Kendall Packards Corner")
      |> assert_text(original_adjustment.source_label)
      |> click(button("save"))
      |> Browser.text(css("h5 span"))
      |> String.to_integer()

    revisions =
      Arrow.Repo.all(
        from d in Arrow.DisruptionRevision,
          preload: [:days_of_week, :adjustments],
          where: d.disruption_id == ^disruption_id
      )

    assert length(revisions) == 3
    revision = Enum.at(revisions, 2)

    assert revision.start_date == now |> DateTime.to_date()
    assert revision.end_date == now |> DateTime.to_date()
    assert revision.row_approved == true
    assert revision.description == "an updated description"
    assert Enum.at(revision.adjustments, 0).source_label == original_adjustment.source_label
    assert Enum.at(revision.adjustments, 1).source_label == added_adjustment.source_label
  end

  feature "can filter disruptions by route", %{session: session} do
    revision = insert(:disruption_revision, adjustment_kind: :red_line)

    session
    |> visit("/")
    |> assert_text(revision.description)
    |> click(xpath("//a[@aria-label='blue line']"))
    |> refute_has(text(revision.description))
  end

  feature "can filter disruptions by ROW status", %{session: session} do
    approved = insert(:disruption_revision, %{row_approved: true})
    pending = insert(:disruption_revision, %{row_approved: false})

    session
    |> visit("/")
    |> assert_text(approved.description)
    |> assert_text(pending.description)
    |> click(link("approved"))
    |> assert_text(approved.description)
    |> refute_has(text(pending.description))
  end

  feature "can show past disruptions", %{session: session} do
    today = Date.utc_today()
    week_ago = Date.add(today, -7)
    yesterday = Date.add(today, -1)
    past = insert(:disruption_revision, %{start_date: week_ago, end_date: yesterday})

    session
    |> visit("/")
    |> refute_has(text(past.description))
    |> click(link("include past"))
    |> assert_text(past.description)
  end

  feature "can view disruption on calendar", %{session: session} do
    revision = insert(build_today_revision())
    adjustment = Enum.at(revision.adjustments, 0)
    disruption = Arrow.Repo.get!(Arrow.Disruption, revision.disruption_id)
    Arrow.Repo.update!(Ecto.Changeset.change(disruption, published_revision_id: revision.id))

    session
    |> visit("/")
    |> click(link("calendar view"))
    |> assert_text(adjustment.source_label)
  end

  @spec build_today_revision() :: Arrow.DisruptionRevision.t()
  defp build_today_revision do
    date = DateTime.now!("America/New_York") |> DateTime.to_date()
    day_name = date |> Calendar.strftime("%A") |> String.downcase()
    day_of_week = build(:day_of_week, %{day_name: day_name})

    build(
      :disruption_revision,
      %{
        start_date: date,
        end_date: date,
        days_of_week: [day_of_week],
        adjustments: [build(:adjustment)]
      }
    )
  end
end
