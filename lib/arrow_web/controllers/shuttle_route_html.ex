defmodule ArrowWeb.ShuttleRouteHTML do
  use ArrowWeb, :html

  embed_templates "shuttle_route_html/*"

  @doc """
  Renders a shuttle_route form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shuttle_route_form(assigns)
end
