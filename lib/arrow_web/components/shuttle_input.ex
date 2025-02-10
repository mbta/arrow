defmodule ArrowWeb.ShuttleInput do
  @moduledoc """
  LiveComponent providing a wrapper around live_select tailored for
  shuttle autocomplete
  """

  alias Phoenix.HTML.FormField
  use ArrowWeb, :live_component

  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle

  attr :id, :string, required: true
  attr :field, :any, required: true
  attr :shuttle, :any, required: true
  attr :label, :string, default: "select shuttle route"
  attr :class, :string, default: nil

  def render(assigns) do
    assigns =
      assign(
        assigns,
        :options,
        if is_nil(assigns.shuttle) || !Ecto.assoc_loaded?(assigns.shuttle) do
          Shuttles.list_shuttles() |> Enum.map(&option_for_shuttle/1)
        else
          [option_for_shuttle(assigns.shuttle)]
        end
      )

    ~H"""
    <div id={@id} class={@class}>
      <.live_select
        field={@field}
        label={@label}
        allow_clear={true}
        target={@myself}
        options={@options}
        placeholder="Search for a route…"
        update_min_len={0}
        value_mapper={&shuttle_value_mapper(&1, assigns.field)}
      />
    </div>
    """
  end

  def handle_event("live_select_change", %{"id" => live_select_id, "text" => text}, socket) do
    new_opts =
      if String.length(text) == 0 do
        Shuttles.list_shuttles() |> Enum.map(&option_for_shuttle/1)
      else
        text |> Shuttles.shuttles_by_search_string() |> Enum.map(&option_for_shuttle/1)
      end

    send_update(LiveSelect.Component, id: live_select_id, options: new_opts)

    {:noreply, socket}
  end

  @spec shuttle_value_mapper(String.t(), %FormField{}) ::
          {String.t(), integer() | String.t()}
  defp shuttle_value_mapper(text, field) do
    shuttle =
      case field.value do
        nil -> nil
        "" -> nil
        shuttle_id -> Shuttles.get_shuttle!(shuttle_id)
      end

    if shuttle == nil do
      {text, text}
    else
      option_for_shuttle(shuttle)
    end
  end

  @spec option_for_shuttle(Shuttle.t()) :: {String.t(), integer()}
  defp option_for_shuttle(%Shuttle{id: id, shuttle_name: shuttle_name}) do
    {shuttle_name, id}
  end
end
