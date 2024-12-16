defmodule ArrowWeb.StopInput do
  @moduledoc """
  LiveComponent providing a wrapper around live_select tailored for
  stop ID autocomplete.
  """

  use ArrowWeb, :live_component

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Stop

  attr :id, :string, required: true
  attr :field, :any, required: true
  attr :label, :string, default: "Stop ID"
  attr :class, :string, default: nil

  def render(assigns) do
    assigns =
      assign(
        assigns,
        :stop,
        Phoenix.HTML.Form.input_value(assigns.field.form, :stop) ||
          Phoenix.HTML.Form.input_value(assigns.field.form, :gtfs_stop)
      )

    # This should only change if the selected value actually changes,
    # not just when a user is typing and options change.
    assigns =
      assign(
        assigns,
        :options,
        if is_nil(assigns.stop) || !Ecto.assoc_loaded?(assigns.stop) do
          []
        else
          [option_for_stop(assigns.stop)]
        end
      )

    ~H"""
    <div id={@id}>
      <.live_select
        field={@field}
        label={@label}
        class={@class}
        allow_clear={true}
        target={@myself}
        options={@options}
      />
    </div>
    """
  end

  def handle_event("live_select_change", %{"id" => live_select_id, "text" => text}, socket) do
    new_opts =
      if String.length(text) < 2 do
        # We only start autocomplete at 2 characters, but there are some 1-character stop IDs
        case Shuttles.stop_or_gtfs_stop_for_stop_id(text) do
          nil -> []
          stop -> [option_for_stop(stop)]
        end
      else
        text |> Shuttles.stops_or_gtfs_stops_by_search_string() |> Enum.map(&option_for_stop/1)
      end

    send_update(LiveSelect.Component, id: live_select_id, options: new_opts)

    {:noreply, socket}
  end

  @spec option_for_stop(Stop.t() | GtfsStop.t()) :: {String.t(), String.t()}
  defp option_for_stop(%Stop{stop_id: stop_id, stop_desc: stop_desc, stop_name: stop_name}),
    do: {"#{stop_id} - #{stop_desc || stop_name}", stop_id}

  defp option_for_stop(%GtfsStop{id: id, desc: desc, name: name}),
    do: {"#{id} - #{desc || name}", id}
end
