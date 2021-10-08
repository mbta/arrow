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
    adjustment = insert(:adjustment)
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
      |> fill_in(css("[aria-label='description']"), with: "a test description")
      |> click(text("Select..."))
      |> click(text(adjustment.source_label))
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

  feature "can filter disruptions by route", %{session: session} do
    revision = insert(create_disruption_revision())

    session
    |> visit("/")
    |> assert_text(revision.description)
    |> click(xpath("//a[@aria-label='Blue']"))
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
    revision = insert(create_disruption_revision())
    adjustment = Enum.at(revision.adjustments, 0)
    disruption = Arrow.Repo.get!(Arrow.Disruption, revision.disruption_id)
    Arrow.Repo.update!(Ecto.Changeset.change(disruption, published_revision_id: revision.id))

    session
    |> visit("/")
    |> click(link("calendar view"))
    |> assert_text(adjustment.source_label)
  end

  defp create_disruption_revision do
    date = DateTime.now!("America/New_York") |> DateTime.to_date()
    day_name = date |> Calendar.strftime("%A") |> String.downcase()
    day_of_week = build(:day_of_week, %{day_name: day_name})

    build(
      :disruption_revision,
      %{
        start_date: date,
        end_date: date,
        days_of_week: [day_of_week]
      }
    )
  end
end