defmodule ArrowWeb.DisruptionComponents do
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Disruptions.Limit
  alias Arrow.Adjustment
  alias ArrowWeb.EditLimitForm

  attr :disruption, DisruptionV2, required: true
  attr :icon_paths, :map, required: true
  attr :editing, :any, required: true

  def view_disruption(assigns) do
    ~H"""
    <div class="border-2 border-dashed border-secondary border-mb-3 p-2 mb-3">
      <div class="flex flex-row">
        <div class="w-50">
          <h4>Title</h4>
          <p>{@disruption.title}</p>
        </div>
        <div class="w-50">
          <h4>Approval Status</h4>
          <%= if @disruption.is_active do %>
            <p>Approved</p>
          <% else %>
            <p>Pending</p>
          <% end %>
        </div>
      </div>
      <div class="w-full">
        <h4>Mode</h4>
        <p>
          <span
            class="m-icon m-icon-sm mr-1"
            style={"background-image: url('#{Map.get(@icon_paths, @disruption.mode)}');"}
          >
          </span>
          {mode_labels()[@disruption.mode]}
        </p>
      </div>
      <div class="flex flex-row">
        <div class="flex-grow">
          <h4>Description</h4>
          <span>{@disruption.description}</span>
        </div>
        <div class="flex flex-col flex-shrink justify-end">
          <.link
            :if={!@editing}
            id="edit-disruption-button"
            class="grow-0 shrink"
            patch={~p"/disruptions/#{@disruption.id}/edit"}
          >
            <.icon name="hero-pencil-solid" class="bg-primary" />
          </.link>
        </div>
      </div>
    </div>
    """
  end

  attr :disruption, DisruptionV2, required: true
  attr :editing, :any, required: true
  attr :icon_paths, :map, required: true

  def view_limits(assigns) do
    ~H"""
    <section id="limits-section" class="py-4 my-4">
      <h3>Limits</h3>
      <%= if Ecto.assoc_loaded?(@disruption.limits) and Enum.any?(@disruption.limits) do %>
        <div class={
          [
            "flex flex-col",
            "md:grid gap-y-4 gap-x-2",
            # buckle up...
            "grid-cols-[[route]_minmax(60px,auto)_[start]_1.5fr_[to]_minmax(40px,auto)_[end]_1.5fr_[startdate]_auto_[enddate]_0.8fr_[days]_1fr_[actions]_minmax(90px,auto)]"
          ]
        }>
          <%= for grouped_limits <- group_limits(@disruption.limits) do %>
            <div class="md:grid md:grid-cols-subgrid col-span-full border-2 border-dashed border-secondary p-3 gap-y-1">
              <div class="hidden md:contents">
                <div class="font-bold col-[route]">Route</div>
                <div class="font-bold col-[start]">Start Stop</div>
                <div class="font-bold col-[end]">End Stop</div>
                <div class="font-bold col-[startdate]">Start Date</div>
                <div class="font-bold col-[enddate]">End Date</div>
                <div class="font-bold col-[days]">Days of Week</div>
              </div>
              <%= for {limit, idx} <- Enum.with_index(grouped_limits) do %>
                <div class="contents text-sm">
                  <%= if idx == 0 do %>
                    <div class="flex flex-row items-center gap-x-1 md:contents">
                      <div class="col-[route] flex flex-row items-center justify-around bg-yellow">
                        <span
                          class="m-icon m-icon-sm"
                          style={"background-image: url('#{get_limit_route_icon_url(limit, @icon_paths)}');"}
                        />
                      </div>
                      <div class="col-[start] flex flex-row items-center font-bold md:font-normal">
                        {limit.start_stop.name}
                      </div>
                      <div class="col-[to] flex flex-row items-center font-bold italic">to</div>
                      <div class="col-[end] flex flex-row items-center font-bold md:font-normal">
                        {limit.end_stop.name}
                      </div>
                    </div>
                  <% end %>
                  <div class="flex flex-row items-center gap-x-2 md:contents">
                    <div class="col-[startdate] flex flex-row items-center">{limit.start_date}</div>
                    <div class="md:hidden">-</div>
                    <div class="col-[enddate] flex flex-row items-center">{limit.end_date}</div>
                    <div class="col-[days] text-sm gap-x-1 flex flex-row items-center">
                      <span
                        :for={dow <- limit.limit_day_of_weeks}
                        class={if(dow.active?, do: "text-primary", else: "text-gray-400")}
                      >
                        {format_day_name_short(dow.day_name)}
                      </span>
                    </div>
                    <div class="col-[actions] flex flex-row items-center">
                      <.link
                        :if={!@editing}
                        patch={~p"/disruptions/#{limit.disruption_id}/limit/#{limit.id}/edit"}
                        class="p-0"
                        type="button"
                        id={"edit-limit-#{limit.id}"}
                      >
                        <.icon name="hero-pencil-solid" class="bg-primary m-icon m-icon-sm" />
                      </.link>
                      <.link
                        :if={!@editing}
                        id={"duplicate-limit-#{limit.id}"}
                        class="p-0"
                        type="button"
                        patch={~p"/disruptions/#{limit.disruption_id}/limit/#{limit.id}/duplicate"}
                      >
                        <.icon
                          name="hero-document-duplicate-solid"
                          class="bg-primary m-icon m-icon-sm"
                        />
                      </.link>
                      <.button
                        :if={!@editing}
                        class="p-0"
                        type="button"
                        phx-click="delete_limit"
                        phx-value-limit={limit.id}
                        data-confirm="Are you sure you want to delete this limit?"
                      >
                        <.icon name="hero-trash-solid" class="bg-primary m-icon m-icon-sm" />
                      </.button>
                    </div>
                  </div>
                </div>
                <%= if @editing == limit do %>
                  <div class="col-span-full">
                    <.live_component
                      module={EditLimitForm}
                      id="edit-limit-form"
                      limit={limit}
                      icon_paths={@icon_paths}
                    />
                  </div>
                <% end %>
              <% end %>
            </div>
          <% end %>
        </div>
      <% end %>
      <.link
        :if={!@editing}
        class="btn-link"
        patch={~p"/disruptions/#{@disruption.id}/limit/new"}
        id="add-limit-component"
      >
        <.icon name="hero-plus" /> <span>add limit component</span>
      </.link>

      <%= if is_struct(@editing, Limit) and !@editing.id do %>
        <.live_component
          module={EditLimitForm}
          id="edit-limit-form"
          limit={@editing}
          icon_paths={@icon_paths}
        />
      <% end %>
    </section>
    """
  end

  defp group_limits(limits) do
    limits
    |> Enum.group_by(&{&1.route_id, &1.start_stop_id, &1.end_stop_id})
    |> Map.values()
  end

  defp get_limit_route_icon_url(limit, icon_paths) do
    kind = Adjustment.kind(%Adjustment{route_id: limit.route.id})
    Map.get(icon_paths, kind)
  end

  # TODO: should this live in a utility module?
  defp format_day_name_short(:monday), do: "M"
  defp format_day_name_short(:tuesday), do: "Tu"
  defp format_day_name_short(:wednesday), do: "W"
  defp format_day_name_short(:thursday), do: "Th"
  defp format_day_name_short(:friday), do: "F"
  defp format_day_name_short(:saturday), do: "Sa"
  defp format_day_name_short(:sunday), do: "Su"

  defp mode_labels,
    do: %{
      subway: "Subway/Light Rail",
      commuter_rail: "Commuter Rail",
      bus: "Bus",
      silver_line: "Silver Line"
    }
end
