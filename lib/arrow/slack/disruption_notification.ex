defmodule Arrow.Slack.DisruptionNotification do
  alias Arrow.DisruptionRevision
  alias ArrowWeb.Router.Helpers, as: Routes
  require EEx

  @spec format_created(DisruptionRevision.t()) :: binary
  def format_created(rev) do
    slack_message(rev, row_status(rev.row_approved))
  end

  @spec format_edited(DisruptionRevision.t(), DisruptionRevision.t()) :: nil | binary
  def format_edited(initial, revised) do
    {ii, ri} = {important_fields(initial), important_fields(revised)}
    IO.inspect(ii)
    IO.inspect(ri)

    if ii != ri do
      header =
        [
          check_dates(ii, ri),
          check_adjustments(ii, ri),
          check_row_status(ii, ri)
        ]
        |> Stream.filter(&(not is_nil(&1)))
        |> Enum.join(", ")

      slack_message(revised, header)
    end

    nil
  end

  @spec format_cancelled(Arrow.DisruptionRevision.t()) :: binary
  def format_cancelled(rev) do
    slack_message(rev, "cancelled")
  end

  def check_dates(rev1, rev2) do
    if rev1.start_date != rev2.start_date ||
         rev1.end_date != rev2.end_date ||
         rev1.exceptions != rev2.exceptions do
      "updated dates"
    else
      nil
    end
  end

  def check_adjustments(rev1, rev2) do
    if rev1.adjustments != rev2.adjustments do
      "updated limits"
    else
      ""
    end
  end

  def check_row_status(rev1, rev2) do
    if rev1.row_approved != rev2.row_approved do
      "status update: #{row_status(rev2.row_approved)}"
    else
      nil
    end
  end

  def row_status(true), do: "Approved"
  def row_status(false), do: "Pending"

  def important_fields(%{
        adjustments: adjustments,
        exceptions: exceptions,
        row_approved: row_approved,
        start_date: start_date,
        end_date: end_date
      }) do
    %{
      adjustments: adjustments |> Enum.map(& &1.id),
      exceptions: exceptions |> Enum.map(& &1.excluded_date),
      row_approved: row_approved,
      start_date: start_date,
      end_date: end_date
    }
  end

  @spec slack_message(DisruptionRevision.t(), String.t()) :: String.t()
  defp slack_message(rev, header) do
    start_date = Calendar.strftime(rev.start_date, "%m/%d/%Y")
    end_date = Calendar.strftime(rev.end_date, "%m/%d/%Y")

    %{
      text:
        disruption_message(
          route_icons(rev),
          header,
          rev.description,
          start_date,
          end_date,
          url(rev),
          rev.disruption_id
        )
    }
    |> Jason.encode!()
  end

  @spec disruption_message(
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          String.t(),
          integer()
        ) :: String.t()
  EEx.function_from_file(:defp, :disruption_message, "lib/arrow/slack/disruption_message.eex", [
    :route_icons,
    :header,
    :description,
    :start_date,
    :end_date,
    :url,
    :id
  ])

  @spec url(DisruptionRevision.t()) :: String.t()
  defp url(rev), do: Routes.disruption_url(ArrowWeb.Endpoint, :show, rev.disruption_id)

  @spec route_icons(DisruptionRevision.t()) :: String.t()
  defp route_icons(rev) do
    for adjustment <-
          rev.adjustments
          |> Enum.sort(&(rank(&1.route_id) < rank(&2.route_id))),
        into: "" do
      icon(adjustment.route_id)
    end
  end

  @spec icon(String.t()) :: String.t()
  def icon("Blue"), do: ":bl:"
  def icon("Orange"), do: ":ol:"
  def icon("Red"), do: ":rl:"
  def icon("Mattapan"), do: ":mattapan:"
  def icon("Green-B"), do: ":glb:"
  def icon("Green-C"), do: ":glc:"
  def icon("Green-D"), do: ":gld:"
  def icon("Green-E"), do: ":gle:"
  def icon("CR-" <> _line), do: ":cr:"

  @spec rank(String.t()) :: integer()
  def rank("Blue"), do: 0
  def rank("Orange"), do: 1
  def rank("Red"), do: 2
  def rank("Mattapan"), do: 3
  def rank("Green-B"), do: 4
  def rank("Green-C"), do: 5
  def rank("Green-D"), do: 6
  def rank("Green-E"), do: 7
  def rank("CR-" <> _line), do: 8
end
