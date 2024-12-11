defmodule ArrowWeb.StopInput do
  use ArrowWeb, :live_component

  attr :id, :string, required: true
  attr :field, :any, required: true
  attr :label, :string, default: "Stop ID"
  attr :class, :string, default: nil

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.live_select field={@field} label={@label} class={@class} allow_clear={true} target={@myself} />
    </div>
    """
  end

  def handle_event("live_select_change", opts, socket) do
    IO.inspect(opts)

    {:noreply, socket}
  end
end
