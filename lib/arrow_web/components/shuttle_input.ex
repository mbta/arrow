defmodule ArrowWeb.ShuttleInput do
  @moduledoc """
  LiveComponent providing a wrapper around live_select tailored for
  shuttle autocomplete
  """

  use ArrowWeb, :live_component

  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle
  alias Phoenix.HTML.FormField

  attr :id, :string, required: true
  attr :field, :any, required: true
  attr :shuttle, :any, required: true
  attr :only_approved?, :boolean, default: false
  attr :label, :string, default: "select shuttle route"
  attr :class, :string, default: nil

  def render(assigns) do
    assigns =
      assign(
        assigns,
        :options,
        if is_nil(assigns.shuttle) || !Ecto.assoc_loaded?(assigns.shuttle) do
          Shuttles.list_shuttles()
          |> filter_only_approved(assigns.only_approved?)
          |> Enum.map(&option_for_shuttle/1)
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
        Shuttles.list_shuttles()
        |> filter_only_approved(socket.assigns.only_approved?)
        |> Enum.map(&option_for_shuttle/1)
      else
        text
        |> Shuttles.shuttles_by_search_string()
        |> filter_only_approved(socket.assigns.only_approved?)
        |> Enum.map(&option_for_shuttle/1)
      end

    send_update(LiveSelect.Component, id: live_select_id, options: new_opts)

    {:noreply, socket}
  end

  # This credo:disable can be removed once a new phoenix_html release is cut
  # https://github.com/phoenixframework/phoenix_html/commit/1bea177dfb6d6e3e326ee60dab87175a6d92e88d
  # credo:disable-for-next-line Credo.Check.Warning.SpecWithStruct
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

  @spec filter_only_approved([Shuttle.t()], boolean()) :: [Shuttle.t()]
  defp filter_only_approved(shuttles, false), do: shuttles

  defp filter_only_approved(shuttles, true) do
    Enum.filter(shuttles, fn shuttle -> shuttle.status == :active end)
  end
end
