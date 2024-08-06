defmodule ArrowWeb.StopView do
  use ArrowWeb, :html

  embed_templates "stop_html/*"

  def format_timestamp(%DateTime{} = dt) do
    dt
    |> DateTime.shift_zone!("America/New_York")
    |> Calendar.strftime("%Y-%m-%d %I:%M %p")
  end
end
