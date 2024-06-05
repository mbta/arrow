defmodule ArrowWeb.ShapeView do
  use ArrowWeb, :html

  embed_templates "shape_html/*"

  @doc """
  Renders a shape form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shape_form(assigns)
end
