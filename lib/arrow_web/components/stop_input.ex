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
  attr :stop_or_gtfs_stop, :any, required: true
  attr :label, :any, default: "Stop ID"
  attr :class, :string, default: nil
  attr :type, :atom, default: nil

  def render(assigns) do
    # This should only change if the selected value actually changes,
    # not just when a user is typing and options change.
    assigns =
      assign(
        assigns,
        :options,
        if is_nil(assigns.stop_or_gtfs_stop) || !Ecto.assoc_loaded?(assigns.stop_or_gtfs_stop) do
          []
        else
          [option_for_stop(assigns.stop_or_gtfs_stop)]
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
        value_mapper={&stop_value_mapper(&1, assigns.field)}
      />
    </div>
    """
  end

  defp stop_value_mapper(text, field) do
    stop =
      case Map.get(field.form.source.changes, :display_stop) do
        %Arrow.Gtfs.Stop{} = stop -> stop
        %Arrow.Shuttles.Stop{} = stop -> stop
        _ -> Shuttles.stop_or_gtfs_stop_for_stop_id(text)
      end

    if stop == nil do
      {text, text}
    else
      option_for_stop(stop)
    end
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
  defp option_for_stop(%Stop{stop_id: stop_id} = stop), do: {"#{stop_id} - #{Shuttles.stop_display_name(stop)}", stop_id}

  defp option_for_stop(%GtfsStop{id: id} = gtfs_stop), do: {"#{id} - #{Shuttles.stop_display_name(gtfs_stop)}", id}
end
