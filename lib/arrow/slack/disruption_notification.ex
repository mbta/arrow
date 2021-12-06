defmodule Arrow.Slack.DisruptionNotification do
  alias ArrowWeb.Router.Helpers, as: Routes
  require EEx

  @type status :: :created | :edited | :cancelled
  defstruct [:revision, :initial, :status]

  def format(%__MODULE__{revision: rev, status: :created}) do
    slack_message(rev, row_status(rev.row_approved))
  end

  def format(%__MODULE__{revision: revised, initial: initial}) do
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
        |> Enum.filter(&(String.length(&1) > 0))
        |> Enum.join(", ")

      slack_message(revised, header)
    end
  end

  def format(%__MODULE__{revision: rev, status: status}) do
    slack_message(rev, status)
  end

  def check_dates(rev1, rev2) do
    if rev1.start_date != rev2.start_date ||
         rev1.end_date != rev2.end_date ||
         rev1.exceptions != rev2.exceptions do
      "updated dates"
    else
      ""
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
      ""
    end
  end

  defp row_status(true), do: "Approved"
  defp row_status(false), do: "Pending"

  defp important_fields(%{
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

  def slack_message(rev, header) do
    start_date = Calendar.strftime(rev.start_date, "%m/%d/%Y")
    end_date = Calendar.strftime(rev.end_date, "%m/%d/%Y")

    %{
      text:
        slack_format(
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

  EEx.function_from_file(:defp, :slack_format, "lib/arrow/slack/slack_message.eex", [
    :route_icons,
    :header,
    :description,
    :start_date,
    :end_date,
    :url,
    :id
  ])

  defp url(rev), do: Routes.disruption_url(ArrowWeb.Endpoint, :show, rev.disruption_id)

  defp route_icons(rev) do
    for adjustment <-
          rev.adjustments
          |> Enum.sort(&(rank(&1.route_id) < rank(&2.route_id))),
        into: "" do
      icon(adjustment.route_id)
    end
  end

  defp icon("Blue"), do: ":bl:"
  defp icon("Orange"), do: ":ol:"
  defp icon("Red"), do: ":rl:"
  defp icon("Mattapan"), do: ":mattapan:"
  defp icon("Green-B"), do: ":glb:"
  defp icon("Green-C"), do: ":glc:"
  defp icon("Green-D"), do: ":gld:"
  defp icon("Green-E"), do: ":gle:"
  defp icon("CR-" <> _line), do: ":cr:"

  defp rank("Blue"), do: 0
  defp rank("Orange"), do: 1
  defp rank("Red"), do: 2
  defp rank("Mattapan"), do: 3
  defp rank("Green-B"), do: 4
  defp rank("Green-C"), do: 5
  defp rank("Green-D"), do: 6
  defp rank("Green-E"), do: 7
  defp rank("CR-" <> _line), do: 8
end
