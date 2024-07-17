defmodule ArrowWeb.StopView do
  use ArrowWeb, :html

  embed_templates "stop_html/*"

  @doc """
  Renders a stop form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def stop_form(assigns)
end
