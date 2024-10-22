defmodule ArrowWeb.ShuttleView do
  use ArrowWeb, :html

  embed_templates "shuttle_html/*"

  @doc """
  Renders a shuttle form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def shuttle_form(assigns)
end
