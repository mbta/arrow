defmodule ArrowWeb.LimitSection do
  @moduledoc """
  LiveComponent used by disruptions to show/create/edit/delete limits
  """

  use ArrowWeb, :live_component

  import Phoenix.HTML.Form
  import Ecto.Query, only: [from: 2]

  alias Arrow.{Adjustment, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit}

  attr :id, :string
  attr :limit_form, :any, required: true
  attr :icon_paths, :map, required: true
  attr :disruption, DisruptionV2, required: true
  attr :limit, Limit
  attr :disabled?, :boolean

  def render(assigns) do
    ~H"""
    <section id={@id}>
      <h3>Limits</h3>
      <%= if Ecto.assoc_loaded?(@disruption.limits) and Enum.any?(@disruption.limits) do %>
        <div class="mb-3 border-2 border-dashed border-secondary border-mb-3 p-3">
          <table class="w-[40rem] sm:w-full">
            <thead>
              <tr>
                <th>route</th>
                <th>start stop</th>
                <th>end stop</th>
                <th>start date</th>
                <th>end date</th>
                <th></th>
              </tr>
            </thead>
            <tbody class="relative divide-y divide-zinc-100 border-t border-zinc-200 text-sm leading-6 text-zinc-700">
              <tr :for={limit <- @disruption.limits}>
                <td>
                  <span
                    class="m-icon m-icon-sm mr-1 align-middle"
                    style={"background-image: url('#{get_limit_route_icon_url(limit, @icon_paths)}');"}
                  />
                </td>
                <td>{limit.start_stop.name}</td>
                <td>{limit.end_stop.name}</td>
                <td>{limit.start_date}</td>
                <td>{limit.end_date}</td>
                <td class="text-center">
                  <.button
                    disabled={!is_nil(@limit_form) or @disabled?}
                    type="button"
                    phx-click="edit_limit"
                    phx-value-limit={limit.id}
                  >
                    <.icon name="hero-pencil-solid" class="bg-primary" />
                  </.button>
                  <.button
                    id={"duplicate-limit-#{limit.id}"}
                    disabled={!is_nil(@limit_form) or @disabled?}
                    type="button"
                    phx-click="duplicate_limit"
                    phx-value-limit={limit.id}
                  >
                    <.icon name="hero-document-duplicate-solid" class="bg-primary" />
                  </.button>
                  <.button
                    disabled={!is_nil(@limit_form) or @disabled?}
                    type="button"
                    phx-click="delete_limit"
                    phx-value-limit={limit.id}
                    phx-target={@myself}
                    data-confirm="Are you sure you want to delete this limit?"
                  >
                    <.icon name="hero-trash-solid" class="bg-primary" />
                  </.button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      <% end %>

      <.button
        :if={is_nil(@limit_form)}
        type="button"
        class="btn-link"
        phx-click="add_limit"
        id="add-limit-component"
        disabled={@disabled?}
      >
        <.icon name="hero-plus" /> <span>add limit component</span>
      </.button>

      <.simple_form
        :if={!is_nil(@limit_form)}
        for={@limit_form}
        id="limit-form"
        phx-submit={@action}
        phx-change="validate"
        phx-target={@myself}
      >
        <input
          value={input_value(@limit_form, :disruption_id)}
          type="hidden"
          name={input_name(@limit_form, :disruption_id)}
        />
        <div class="container border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            {if @action == "create", do: "add new disruption limit", else: "edit disruption limit"}
          </h4>
          <div class="row mb-3">
            <div class="col-lg-3">
              <.input
                class="h-100"
                id="select-route-id"
                field={@limit_form[:route_id]}
                type="select"
                label="route"
                prompt="Choose a route"
                options={get_route_options()}
              />
            </div>
            <div class="col-lg-3">
              <.input
                class="h-100"
                field={@limit_form[:start_stop_id]}
                type="select"
                label="start stop"
                prompt="Choose a stop"
                disabled={input_value(@limit_form, :route_id) in [nil, ""]}
                options={get_stops_for_route(input_value(@limit_form, :route_id))}
              />
            </div>
            <div class="align-self-end">
              to
            </div>
            <div class="col-lg-3">
              <.input
                class="h-100"
                field={@limit_form[:end_stop_id]}
                type="select"
                label="end stop"
                prompt="Choose a stop"
                disabled={input_value(@limit_form, :route_id) in [nil, ""]}
                options={get_stops_for_route(input_value(@limit_form, :route_id))}
              />
            </div>
          </div>
          <div class="row mb-3">
            <.input class="col-lg-3" field={@limit_form[:start_date]} type="date" label="start date" />
            <.input class="col-lg-3" field={@limit_form[:end_date]} type="date" label="end date" />
          </div>
          <div class="container justify-content-around mb-3">
            <.inputs_for :let={f_day_of_week} field={@limit_form[:limit_day_of_weeks]}>
              <div class="row">
                <input
                  value={input_value(f_day_of_week, :day_name)}
                  type="hidden"
                  name={input_name(f_day_of_week, :day_name)}
                />
                <div class="col col-lg-1">
                  <.input type="checkbox" field={f_day_of_week[:active?]} />
                </div>
                <div class="col col-lg-2">
                  <div class="border-2 border-solid border-primary text-center py-2 rounded-lg">
                    {format_day_name(input_value(f_day_of_week, :day_name))}
                  </div>
                </div>
                <div class="col col-lg-3">
                  <.input
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    field={f_day_of_week[:start_time]}
                    disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                    phx-hook="LimitTime"
                  />
                </div>
                <div class="col col-lg-3">
                  <.input
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    field={f_day_of_week[:end_time]}
                    disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                    phx-hook="LimitTime"
                  />
                </div>
                <div class="col">
                  <div
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    class="flex"
                  >
                    <.input
                      class="mr-2"
                      field={f_day_of_week[:all_day?]}
                      type="checkbox"
                      label="all day"
                    />
                  </div>
                </div>
              </div>
            </.inputs_for>
          </div>
          <div class="row">
            <div class="col-lg-3">
              <.button type="submit" class="btn-primary btn-sm w-100" phx-target={@myself}>
                save limit
              </.button>
            </div>
            <div class="col-lg-3">
              <.button
                type="button"
                id="cancel_add_limit_button"
                class="btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this limit will be lost!"
                phx-click="cancel_add_limit"
                phx-target={@myself}
              >
                cancel
              </.button>
            </div>
          </div>
        </div>
      </.simple_form>
    </section>
    """
  end

  def update(%{limit: nil} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(limit_form: nil)
     |> assign(action: "create")}
  end

  def update(assigns, socket) do
    limit_form = assigns.limit |> Limits.change_limit() |> to_form()
    action = if is_nil(assigns.limit.id), do: "create", else: "update"

    {:ok,
     socket
     |> assign(assigns)
     |> assign(limit_form: limit_form)
     |> assign(action: action)}
  end

  def handle_event("validate", %{"limit" => limit_params}, socket) do
    form =
      socket.assigns.limit
      |> Limits.change_limit(%{limit_params | "disruption_id" => socket.assigns.disruption.id})
      |> to_form(action: :validate)

    {:noreply, assign(socket, limit_form: form)}
  end

  def handle_event("create", %{"limit" => limit_params}, socket) do
    case Limits.create_limit(limit_params) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Limit created successfully"})

        {:noreply,
         socket
         |> assign(limit: nil)
         |> assign(limit_form: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, limit_form: to_form(changeset))}
    end
  end

  def handle_event("update", %{"limit" => limit_params}, socket) do
    limit = Limits.get_limit!(socket.assigns.limit.id)

    case(Limits.update_limit(limit, limit_params)) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Limit updated successfully"})

        {:noreply,
         socket
         |> assign(limit: nil)
         |> assign(limit_form: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, limit_form: to_form(changeset))}
    end
  end

  def handle_event("cancel_add_limit", _params, socket) do
    send(self(), :cancel_limit_form)

    {:noreply,
     socket
     |> assign(limit: nil)
     |> assign(limit_form: nil)}
  end

  def handle_event("delete_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)
    limit = Limits.get_limit!(parsed_id)

    case Limits.delete_limit(limit) do
      {:ok, _} ->
        send(self(), :update_disruption)
        send(self(), {:put_flash, :info, "Limit deleted successfully"})
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        send(self(), {:put_flash, :error, "Error when deleting limit!"})
        {:noreply, assign(socket, limit: to_form(changeset))}
    end
  end

  defp get_route_options do
    from(r in Arrow.Gtfs.Route, where: r.type in [:light_rail, :heavy_rail])
    |> Arrow.Repo.all()
    |> Enum.map(&{&1.long_name, &1.id})
  end

  defp get_stops_for_route(nil), do: []

  defp get_stops_for_route(route_id) do
    Arrow.Repo.all(
      from t in Arrow.Gtfs.Trip,
        where: t.route_id == ^route_id and t.direction_id == 0 and t.service_id == "canonical",
        join: st in Arrow.Gtfs.StopTime,
        on: t.id == st.trip_id,
        join: s in Arrow.Gtfs.Stop,
        on: s.id == st.stop_id,
        where: s.location_type == :stop_platform,
        select: s,
        order_by: st.stop_sequence
    )
    |> Enum.uniq_by(& &1.parent_station_id)
    |> Enum.map(&{&1.name, &1.parent_station_id})
  end

  defp format_day_name(day_name) when is_atom(day_name) do
    day_name |> Atom.to_string() |> format_day_name()
  end

  defp format_day_name(day_name) do
    day_name
    |> String.slice(0..2)
    |> String.capitalize()
  end

  defp get_limit_route_icon_url(limit, icon_paths) do
    kind = Adjustment.kind(%Adjustment{route_id: limit.route.id})
    Map.get(icon_paths, kind)
  end
end
