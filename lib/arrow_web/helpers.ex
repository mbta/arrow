defmodule ArrowWeb.Helpers do
  def format_day_name_short(:monday), do: "M"
  def format_day_name_short(:tuesday), do: "Tu"
  def format_day_name_short(:wednesday), do: "W"
  def format_day_name_short(:thursday), do: "Th"
  def format_day_name_short(:friday), do: "F"
  def format_day_name_short(:saturday), do: "Sa"
  def format_day_name_short(:sunday), do: "Su"

  def format_day_name(day_name) when is_atom(day_name) do
    day_name |> Atom.to_string() |> format_day_name()
  end

  def format_day_name(day_name) do
    day_name
    |> String.slice(0..2)
    |> String.capitalize()
  end

  @line_icon_names %{
    "line-Blue" => :blue_line,
    "line-Green" => :green_line,
    "line-Orange" => :orange_line,
    "line-Red" => :red_line,
    "line-Mattapan" => :mattapan_line
  }

  def line_icon_path(icon_paths, line_id) do
    Map.get(icon_paths, @line_icon_names[line_id])
  end

  def mode_labels,
    do: [
      subway: "Subway/Light Rail",
      commuter_rail: "Commuter Rail",
      bus: "Bus",
      silver_line: "Silver Line"
    ]
end
