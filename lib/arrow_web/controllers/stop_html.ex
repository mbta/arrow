defmodule ArrowWeb.StopView do
  use ArrowWeb, :html

  embed_templates "stop_html/*"

  @doc """
  Renders a stop form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def stop_form(assigns)

  def format_timestamp(%DateTime{} = dt) do
    dt
    |> DateTime.shift_zone!("America/New_York")
    |> Calendar.strftime("%Y-%m-%d %I:%M %p")
  end

  def sort_link(nil, field), do: ~p"/stops?#{%{order_by: "#{field}_desc"}}"

  def sort_link(sort_by, field) do
    if sort_by == "#{field}_desc" do
      ~p"/stops?#{%{order_by: "#{field}_asc"}}"
    else
      ~p"/stops?#{%{order_by: "#{field}_desc"}}"
    end
  end
end
