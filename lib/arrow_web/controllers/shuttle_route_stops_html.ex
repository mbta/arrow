defmodule ArrowWeb.ShuttleRouteStopsView do
  use ArrowWeb, :html

  embed_templates "shuttle_route_stops_html/*"

  @doc """
  Renders a shuttle_route_stops form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shuttle_route_stops_form(assigns)
end
