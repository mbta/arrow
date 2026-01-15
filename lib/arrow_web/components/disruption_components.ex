defmodule ArrowWeb.DisruptionComponents do
  @moduledoc false
  alias Arrow.Disruptions.ReplacementService
  use ArrowWeb, :live_component

  alias Arrow.Adjustment
  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Disruptions.Limit
  alias Arrow.Hastus.Export, as: HastusExport
  alias Arrow.Hastus.Service
  alias ArrowWeb.EditHastusExportForm
  alias ArrowWeb.EditLimitForm
  alias ArrowWeb.EditReplacementServiceForm
  alias ArrowWeb.EditTrainsformerExportForm

  attr :disruption, DisruptionV2, required: true
  attr :icon_paths, :map, required: true
  attr :editing, :any, required: true

  def view_disruption(assigns) do
    ~H"""
    <div
      class="border-2 border-dashed border-secondary border-mb-3 p-2 mb-3"
      phx-mounted={
        JS.show(
          transition: {"ease-out duration-300", "opacity-0 max-h-0", "opacity-100 max-h-screen"},
          time: 300
        )
      }
      phx-remove={
        JS.hide(
          transition: {"ease-out duration-300", "opacity-100 max-h-screen", "opacity-0 max-h-0"},
          time: 300
        )
      }
    >
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
          <div style="white-space: pre-wrap;">{@disruption.description}</div>
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
      <%= if DisruptionV2.has_limits?(@disruption) do %>
        <div class={
          [
            "mb-3",
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
                <%= if @editing && is_struct(@editing, Limit) && @editing.id == limit.id do %>
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
          <%= for export <- @disruption.hastus_exports,
                  derived_limits = Enum.with_index(imported_derived_limits(export)),
                  derived_limits != [] do %>
            <div class="md:grid md:grid-cols-subgrid col-span-full border-2 border-dashed border-secondary p-3 gap-y-1">
              <div class="hidden md:contents">
                <div class="font-bold col-[route]">Route</div>
                <div class="font-bold col-[start]">Start Stop</div>
                <div class="font-bold col-[end]">End Stop</div>
                <div class="font-bold col-[startdate]">Start Date</div>
                <div class="font-bold col-[enddate]">End Date</div>
                <div class="font-bold col-[days]">Days of Week</div>
                <div class="font-bold col-[actions]">Via HASTUS</div>
              </div>
              <div :for={{derived_limit, idx} <- derived_limits} class="contents text-sm">
                <div class="flex flex-row items-center gap-x-1 md:contents">
                  <%= if idx == 0 do %>
                    <div class="col-[route] flex flex-row items-center justify-around">
                      <span
                        class="m-icon m-icon-sm"
                        style={"background-image: url('#{get_line_icon_url(derived_limit, @icon_paths)}');"}
                      />
                    </div>
                  <% end %>
                  <div class="col-[start] flex flex-row items-center font-bold md:font-normal">
                    {derived_limit.start_stop_name}
                  </div>
                  <div class="col-[to] flex flex-row items-center font-bold italic">to</div>
                  <div class="col-[end] flex flex-row items-center font-bold md:font-normal">
                    {derived_limit.end_stop_name}
                  </div>
                </div>
                <div class="flex flex-row items-center gap-x-2 md:contents">
                  <div class="col-[startdate] flex flex-row items-center">
                    {derived_limit.start_date}
                  </div>
                  <div class="md:hidden">-</div>
                  <div class="col-[enddate] flex flex-row items-center">{derived_limit.end_date}</div>
                  <div class="col-[days] text-sm gap-x-1 flex flex-row items-center">
                    <span
                      :for={dow <- derived_limit.day_of_weeks}
                      class={if(dow.active?, do: "text-primary", else: "text-gray-400")}
                    >
                      {format_day_name_short(dow.day_name)}
                    </span>
                  </div>
                  <%= if idx == 0 do %>
                    <div class="col-[actions] flex flex-row items-center">
                      <% export_el_id = "export-table-hastus-#{export.id}" %>
                      <.link
                        class="font-italic max-sm:invisible max-md:max-w-[11rem] md:visible md:max-w-xs truncate pr-1"
                        title="Jump to source HASTUS export of this derived limit"
                        onclick={"document.getElementById('#{export_el_id}').scrollIntoView({behavior:'smooth',block:'nearest'})"}
                        phx-click={
                          JS.transition("animate-grow-shrink", time: 300, to: "##{export_el_id}")
                        }
                      >
                        <.icon name="hero-arrow-long-right" class="visible m-icon m-icon-sm" /><.icon
                          name="hero-table-cells"
                          class="visible m-icon m-icon-sm"
                        />
                        {derived_limit.export_filename}
                      </.link>
                    </div>
                  <% end %>
                </div>
              </div>
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
        <.icon name="hero-plus" /> <span>Add limit component</span>
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

  attr :disruption, DisruptionV2, required: true
  attr :editing, :any, required: true
  attr :icon_paths, :map, required: true
  attr :user_id, :string, required: true

  def view_hastus_service_schedules(assigns) do
    ~H"""
    <section id="hastus_service_schedules" class="py-4 my-4">
      <h3>HASTUS Service Schedules</h3>
      <%= if Ecto.assoc_loaded?(@disruption.hastus_exports) and Enum.any?(@disruption.hastus_exports) do %>
        <div
          :for={export <- @disruption.hastus_exports}
          id={"export-table-hastus-#{export.id}"}
          class="border-2 border-dashed border-secondary border-mb-3 p-2 mb-3"
        >
          <% imported_services = Enum.filter(export.services, & &1.import?) %>
          <table class="w-[40rem] sm:w-full">
            <thead>
              <tr>
                <th>route</th>
                <th>service ID</th>
                <th>start date</th>
                <th>end date</th>
                <th></th>
              </tr>
            </thead>
            <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
              <tr :for={{service, i} <- Enum.with_index(imported_services)}>
                <td class="align-top">
                  <span
                    :if={i == 0}
                    class="m-icon m-icon-sm mr-1"
                    style={"background-image: url('#{line_icon_path(@icon_paths, export.line.id)}');"}
                  />
                </td>
                <td class="align-top">{service.name}</td>
                <td>
                  <div :for={date <- Enum.map(service.service_dates, & &1.start_date)}>
                    <span class="text-danger">{Calendar.strftime(date, "%a")}.</span>
                    {Calendar.strftime(date, "%m/%d/%Y")}
                  </div>
                </td>
                <td>
                  <div :for={date <- Enum.map(service.service_dates, & &1.end_date)}>
                    <span class="text-danger">{Calendar.strftime(date, "%a")}.</span>
                    {Calendar.strftime(date, "%m/%d/%Y")}
                  </div>
                </td>
                <td :if={i == length(imported_services) - 1}>
                  <div class="text-right">
                    <.link
                      :if={!@editing}
                      id={"edit-export-button-#{export.id}"}
                      class="btn-sm p-0"
                      patch={~p"/disruptions/#{@disruption.id}/hastus_export/#{export.id}/edit"}
                    >
                      <.icon name="hero-pencil-solid" class="bg-primary" />
                    </.link>
                    <.button
                      :if={!@editing}
                      id={"delete-export-button-#{export.id}"}
                      class="btn-sm p-0"
                      type="button"
                      phx-click="delete_export"
                      phx-value-export={export.id}
                      data-confirm="Are you sure you want to delete this export?"
                    >
                      <.icon name="hero-trash-solid" class="bg-primary" />
                    </.button>
                  </div>
                </td>
              </tr>
              <%= if @editing && is_struct(@editing, Arrow.Hastus.Export) && @editing.id == export.id do %>
                <tr>
                  <td colspan="4">
                    <.live_component
                      module={EditHastusExportForm}
                      id="hastus-export-edit-form"
                      disruption={@disruption}
                      export={@editing}
                      icon_paths={@icon_paths}
                      user_id={@user_id}
                    />
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      <% end %>
      <.link
        :if={!@editing}
        patch={~p"/disruptions/#{@disruption.id}/hastus_export/new"}
        id="upload-hastus-export-component"
      >
        <.icon name="hero-plus" />
        <span>Upload HASTUS export</span>
      </.link>

      <%= if is_struct(@editing, Arrow.Hastus.Export) and !@editing.id do %>
        <.live_component
          module={EditHastusExportForm}
          id="hastus-export-edit-form"
          disruption={@disruption}
          export={@editing}
          icon_paths={@icon_paths}
          user_id={@user_id}
        />
      <% end %>
    </section>
    """
  end

  attr :disruption, DisruptionV2, required: true
  attr :editing, :any, required: true
  attr :user_id, :string, required: true
  attr :icon_paths, :map, required: true

  def view_trainsformer_service_schedules(assigns) do
    ~H"""
    <section id="trainsformer_service_schedules" class="py-4 my-4">
      <h3>Trainsformer Service Schedules</h3>
      <%= if Ecto.assoc_loaded?(@disruption.trainsformer_exports) and Enum.any?(@disruption.trainsformer_exports) do %>
        <div
          :for={export <- @disruption.trainsformer_exports}
          id={"export-table-hastus-#{export.id}"}
          class="border-2 border-dashed border-secondary border-mb-3 p-2 mb-3"
        >
          <p><b>Export:</b> {export.name}</p>
          <div class="row">
            <div class="col-3">
              <b>Routes</b>
              <%= for route <- export.routes do %>
                <div class="row">
                  <div class="col-lg-1">
                    <span
                      class="m-icon m-icon-sm mr-1"
                      style={"background-image: url('#{Map.get(@icon_paths, :commuter_rail)}');"}
                    />
                  </div>
                  <div class="col-lg-10">
                    <p>{route.route_id}</p>
                  </div>
                </div>
              <% end %>
            </div>

            <div class="col-9">
              <table class="sm:w-full">
                <tr>
                  <th>
                    Service
                  </th>
                  <th>
                    Start Date
                  </th>
                  <th>
                    End Date
                  </th>
                  <th>
                    Days of Week
                  </th>
                </tr>
                <%= for service <- export.services do %>
                  <tr>
                    <td>{service.name}</td>
                    <td>
                      <div :for={date <- Enum.map(service.service_dates, & &1.start_date)}>
                        <span class="text-danger">{Calendar.strftime(date, "%a")}.</span>
                        {Calendar.strftime(date, "%m/%d/%Y")}
                      </div>
                    </td>
                    <td>
                      <div :for={date <- Enum.map(service.service_dates, & &1.end_date)}>
                        <span class="text-danger">{Calendar.strftime(date, "%a")}.</span>
                        {Calendar.strftime(date, "%m/%d/%Y")}
                      </div>
                    </td>
                    <td>
                      <span
                        :for={dow <- Arrow.Util.DayOfWeek.get_all_day_names()}
                        class="text-gray-400"
                      >
                        {format_day_name_short(dow)}
                      </span>
                    </td>
                  </tr>
                <% end %>
              </table>
            </div>
          </div>
        </div>
      <% end %>

      <.link
        :if={!@editing}
        patch={~p"/disruptions/#{@disruption.id}/trainsformer_export/new"}
        id="upload-hastus-export-component"
      >
        <.icon name="hero-plus" />
        <span>Upload Trainsformer export</span>
      </.link>

      <%= if is_struct(@editing, Arrow.Trainsformer.Export) and !@editing.id do %>
        <.live_component
          module={EditTrainsformerExportForm}
          id="trainsformer-export-edit-form"
          disruption={@disruption}
          export={@editing}
          user_id={@user_id}
          icon_paths={@icon_paths}
        />
      <% end %>
    </section>
    """
  end

  attr :disruption, DisruptionV2, required: true
  attr :editing, :any, required: true
  attr :icon_paths, :map, required: true

  def view_replacement_services(assigns) do
    ~H"""
    <section id="replacement_services_section" class="py-4 my-4">
      <h3>Replacement Service</h3>
      <%= if Ecto.assoc_loaded?(@disruption.replacement_services) and Enum.any?(@disruption.replacement_services) do %>
        <div
          :for={replacement_service <- @disruption.replacement_services}
          class="container-fluid border-2 border-dashed border-secondary border-mb-3 p-3 mb-3"
        >
          <div class="row">
            <div class="col-lg-1 pr-lg-0">
              <span
                class="m-icon m-icon-lg"
                style={"background-image: url('#{Map.get(@icon_paths, :bus_outline)}');"}
              />
            </div>
            <div class="col pl-lg-0">
              {replacement_service.shuttle.shuttle_name}
              <div class="text-sm">
                Activated via <i>{replacement_service.source_workbook_filename}</i>
              </div>
            </div>
            <div class="col-lg-3 text-sm">
              <div>start date</div>
              <div>
                {replacement_service.start_date}
              </div>
            </div>
            <div class="col-lg-3 text-sm">
              <div>end date</div>
              {replacement_service.end_date}
            </div>
          </div>
          <div class="row mt-3">
            <div class="flex justify-between w-full px-3 py-2">
              <div>
                <.link
                  :if={!@editing}
                  class="btn-link btn-sm pl-0"
                  id={"edit_replacement_service-#{replacement_service.id}"}
                  patch={
                    ~p"/disruptions/#{@disruption.id}/replacement_services/#{replacement_service.id}/edit"
                  }
                >
                  <.icon name="hero-pencil-solid" class="bg-primary" /> Edit/Manage Activation
                </.link>
                <a
                  class="btn-link btn-sm pl-0"
                  href={~p"/replacement_services/#{replacement_service.id}/timetable"}
                  target="_blank"
                >
                  <.icon name="hero-table-cells" class="bg-primary" /> View Parsed Timetables
                </a>
              </div>
              <div>
                <.button
                  :if={!@editing}
                  class="btn-sm"
                  type="button"
                  phx-click="delete_replacement_service"
                  phx-value-replacement_service={replacement_service.id}
                  data-confirm="Are you sure you want to delete this replacement service?"
                >
                  <.icon name="hero-trash-solid" class="bg-primary" />
                </.button>
              </div>
            </div>
          </div>
          <%= if @editing && is_struct(@editing, ReplacementService) && @editing.id == replacement_service.id do %>
            <div class="row">
              <div class="col-12">
                <.live_component
                  id="edit_replacement_service_form"
                  module={EditReplacementServiceForm}
                  disruption={@disruption}
                  replacement_service={@editing}
                  icon_paths={@icon_paths}
                />
              </div>
            </div>
          <% end %>
        </div>
      <% end %>

      <.link
        :if={!@editing}
        type="button"
        id="add_replacement_service"
        class="btn-link"
        patch={~p"/disruptions/#{@disruption.id}/replacement_services/new"}
      >
        <.icon name="hero-plus" /> <span>Add replacement service component</span>
      </.link>

      <%= if @editing && is_struct(@editing, ReplacementService) && !@editing.id do %>
        <.live_component
          id="edit_replacement_service_form"
          module={EditReplacementServiceForm}
          disruption={@disruption}
          replacement_service={@editing}
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

  defp get_line_icon_url(%{line_id: line_id}, icon_paths) do
    Map.get(icon_paths, icon_for_line(line_id))
  end

  defp icon_for_line("line-Blue"), do: :blue_line
  defp icon_for_line("line-Orange"), do: :orange_line
  defp icon_for_line("line-Red"), do: :red_line
  defp icon_for_line("line-Mattapan"), do: :mattapan_line
  defp icon_for_line("line-Green"), do: :green_line

  @spec imported_derived_limits(HastusExport.t()) :: [map]
  defp imported_derived_limits(export) do
    for %{import?: true} = service <- export.services,
        limit <- service.derived_limits do
      active_day_of_weeks = Service.day_of_weeks(service)

      day_of_weeks =
        Enum.map(
          Arrow.Util.DayOfWeek.get_all_day_names(),
          &%{day_name: &1, active?: &1 in active_day_of_weeks}
        )

      %{
        line_id: export.line.id,
        export_filename: Path.basename(export.s3_path),
        start_stop_name: limit.start_stop.name,
        end_stop_name: limit.end_stop.name,
        start_date: Service.first_date(service),
        end_date: Service.last_date(service),
        day_of_weeks: day_of_weeks
      }
    end
  end
end
