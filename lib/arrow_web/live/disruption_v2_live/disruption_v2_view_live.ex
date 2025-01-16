defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  import Phoenix.HTML.Form
  import Ecto.Query, only: [from: 2]

  alias Arrow.{Adjustment, Disruptions, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit}

  @days ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]

  @spec disruption_status_labels :: map()
  def disruption_status_labels, do: %{Approved: true, Pending: false}

  @spec mode_labels :: map()
  def mode_labels,
    do: %{
      Subway: :subway,
      "Commuter Rail": :commuter_rail,
      Bus: :bus,
      "Silver Line": :silver_line
    }

  def days, do: @days

  attr :id, :string
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :disruption_v2, DisruptionV2, required: true
  attr :icon_paths, :map, required: true
  attr :errors, :map, default: %{}
  attr :show_service_form?, :boolean
  attr :show_limit_form?, :boolean

  def disruption_form(assigns) do
    ~H"""
    <div class="w-75">
      <.simple_form for={@form} id="disruption_v2-form" phx-submit="save" phx-change="validate">
        <div class="flex flex-row">
          <fieldset class="w-50">
            <legend>Title</legend>
            <.input field={@form[:title]} type="text" placeholder="Add text" />
          </fieldset>
          <fieldset class="w-50 ml-20">
            <legend>Approval Status</legend>
            <div :for={{{status, value}, idx} <- Enum.with_index(disruption_status_labels())} %>
              <label class="form-check form-check-label">
                <input
                  name={@form[:is_active].name}
                  id={"#{@form[:is_active].id}-#{idx}"}
                  class="form-check-input"
                  type="radio"
                  checked={to_string(@form[:is_active].value) == to_string(value)}
                  value={to_string(value)}
                />
                {status}
              </label>
            </div>
          </fieldset>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <div :for={{{mode, value}, idx} <- Enum.with_index(mode_labels())}>
            <label class="form-check form-check-label">
              <input
                name={@form[:mode].name}
                id={"#{@form[:mode].id}-#{idx}"}
                class="form-check-input"
                type="radio"
                checked={to_string(@form[:mode].value) == to_string(value)}
                value={to_string(value)}
              />

              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{Map.get(@icon_paths, value)}');"}
              >
              </span>
              {mode}
            </label>
          </div>
        </fieldset>
        <fieldset>
          <legend>Description</legend>
          <.input
            type="textarea"
            class="form-control"
            cols={30}
            field={@form[:description]}
            aria-describedby="descriptionHelp"
            aria-label="description"
          />

          <small id="descriptionHelp" class="form-text">
            please include: types of disruption, place, and reason
          </small>
        </fieldset>

        <.limit_form_section
          form={@form}
          show_limit_form?={@show_limit_form?}
          existing_limits={@disruption_v2.limits}
        />

        <.replacement_service_section form={@form} show_service_form?={@show_service_form?} />

        <:actions>
          <div class="w-25 mr-2">
            <.button type="submit" disabled={not Enum.empty?(@errors)} class="btn btn-primary w-100">
              Save Disruption
            </.button>
          </div>
          <div class="w-25 mr-2">
            <.link_button
              href={~p"/"}
              class="btn-outline-primary w-100"
              data-confirm="Are you sure you want to cancel? All changes will be lost!"
            >
              Cancel
            </.link_button>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  attr :show_service_form?, :boolean, required: true
  attr :form, :any, required: true

  defp replacement_service_section(assigns) do
    ~H"""
    <h3>Replacement Service</h3>
    <div>
      <span :if={!@show_service_form?} class="text-primary">
        <button
          id="add_new_replacement_service_button"
          class="btn"
          type="button"
          phx-click="add_new_replacement_service"
        >
          <.icon name="hero-plus" class="h-8 w-8 text-primary" />
        </button>
        <label for="add_new_replacement_service_button">add replacement service component</label>
      </span>
      <div :if={@show_service_form?} class="border-2 border-dashed border-primary p-2">
        <span class="text-primary">add new replacement service component</span>
        <.shuttle_input field={@form[:new_shuttle_id]} shuttle={input_value(@form, :new_shuttle)} />
        <div class="row">
          <.input
            field={@form[:new_shuttle_start_date]}
            type="date"
            label="Start date"
            class="col-lg-3"
          />
          <.input field={@form[:new_shuttle_end_date]} type="date" label="End date" class="col-lg-3" />
          <.input field={@form[:new_shuttle_activation_reason]} type="text" label="Activation reason" />
        </div>
        <div class="row">
          <div class="col-lg-3">
            <.button disabled={not Enum.empty?(@form.source.errors)} class="btn btn-primary w-100">
              save component
            </.button>
          </div>
          <div class="col-lg-3">
            <.button
              id="cancel_add_new_replacement_service_button"
              class="btn-outline-primary w-100"
              data-confirm="Are you sure you want to cancel? All changes to this replacement service component will be lost!"
              phx-click="cancel_add_new_replacement_service"
            >
              cancel
            </.button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :form, :any, required: true
  attr :existing_limits, :any
  attr :show_limit_form?, :boolean, required: true

  defp limit_form_section(assigns) do
    ~H"""
    <h3>Limits</h3>
    <%= if Ecto.assoc_loaded?(@existing_limits) do %>
      <div class="mb-3">
        <.table :if={Enum.any?(@existing_limits)} id="limits" rows={@existing_limits}>
          <:col :let={limit} label="route">{limit.route_id}</:col>
          <:col :let={limit} label="start stop">{limit.start_stop.name}</:col>
          <:col label=""><b>to</b></:col>
          <:col :let={limit} label="end stop">{limit.end_stop.name}</:col>
          <:col :let={limit} label="start date">{limit.start_date}</:col>
          <:col :let={limit} label="end date">{limit.end_date}</:col>
          <:action :let={limit}>
            <.button
              disabled={@show_limit_form?}
              type="button"
              phx-click="edit_limit"
              phx-value-limit={limit.id}
            >
              <.icon name="hero-pencil-solid" class="bg-primary" />
            </.button>
            <.button disabled={@show_limit_form?} type="button">
              <.icon name="hero-document-duplicate-solid" class="bg-primary" />
            </.button>
            <.button disabled={@show_limit_form?} type="button">
              <.icon name="hero-trash-solid" class="bg-primary" />
            </.button>
          </:action>
        </.table>
      </div>
    <% end %>
    <.link_button :if={!@show_limit_form?} class="btn-link" phx-click="add_limit">
      <.icon name="hero-plus" /> <span>add limit component</span>
    </.link_button>
    <.inputs_for :let={f_limit} field={@form[:limits]}>
      <div
        :if={
          @show_limit_form? and
            (is_nil(f_limit.data.id) or input_value(f_limit, :editing?) == true)
        }
        class="container border-2 border-dashed border-primary p-3"
      >
        <input
          value={input_value(f_limit, :editing?)}
          type="hidden"
          name={input_name(f_limit, :editing?)}
        />
        <h4 class="text-primary">add new disruption limit</h4>
        <div class="row mb-3">
          <div class="col-lg-3">
            <.input
              class="h-100"
              field={f_limit[:route_id]}
              type="select"
              label="route"
              prompt="Choose a route"
              options={get_route_options()}
            />
          </div>
          <div class="col-lg-3">
            <.input
              class="h-100"
              field={f_limit[:start_stop_id]}
              type="select"
              label="start stop"
              prompt="Choose a stop"
              disabled={input_value(f_limit, :route_id) in [nil, ""]}
              options={get_stops_for_route(input_value(f_limit, :route_id))}
            />
          </div>
          <div class="align-self-end">
            to
          </div>
          <div class="col-lg-3">
            <.input
              class="h-100"
              field={f_limit[:end_stop_id]}
              type="select"
              label="end stop"
              prompt="Choose a stop"
              disabled={input_value(f_limit, :route_id) in [nil, ""]}
              options={get_stops_for_route(input_value(f_limit, :route_id))}
            />
          </div>
        </div>
        <div class="row mb-3">
          <.input class="col-lg-3" field={f_limit[:start_date]} type="date" label="start date" />
          <.input class="col-lg-3" field={f_limit[:end_date]} type="date" label="end date" />
        </div>
        <div class="container justify-content-around mb-3">
          <.inputs_for :let={f_day_of_week} field={f_limit[:limit_day_of_weeks]}>
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
              <div class="col col-lg-2">
                <input
                  :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                  value={input_value(f_day_of_week, :start_time)}
                  name={input_value(f_day_of_week, :start_time)}
                  type="time"
                  disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                />
              </div>
              <div class="col col-lg-2">
                <input
                  :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                  value={input_value(f_day_of_week, :end_time)}
                  name={input_value(f_day_of_week, :end_time)}
                  type="time"
                  disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                />
              </div>
              <div class="col col-lg-1">
                <.input
                  :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                  field={f_day_of_week[:all_day?]}
                  type="checkbox"
                />
              </div>
            </div>
          </.inputs_for>
        </div>
        <div class="row">
          <div class="col-lg-3">
            <.button class="btn btn-primary w-100">
              save limit
            </.button>
          </div>
          <div class="col-lg-3">
            <.button
              id="cancel_add_limit_button"
              class="btn-outline-primary w-100"
              data-confirm="Are you sure you want to cancel? All changes to this limit will be lost!"
              phx-click="cancel_add_limit"
            >
              cancel
            </.button>
          </div>
        </div>
      </div>
    </.inputs_for>
    """
  end

  defp get_route_options do
    from(r in Arrow.Gtfs.Route, where: r.type in [:light_rail, :heavy_rail])
    |> Arrow.Repo.all()
    |> Enum.map(&{&1.long_name, &1.id})
  end

  defp get_stops_for_route(nil), do: []

  defp get_stops_for_route(route_id) do
    Arrow.Repo.all(
      from s in Arrow.Gtfs.Stop,
        where: s.location_type == :stop_platform,
        join: st in Arrow.Gtfs.StopTime,
        on: s.id == st.stop_id,
        join: t in Arrow.Gtfs.Trip,
        on: st.trip_id == t.id,
        where: t.route_id == ^route_id,
        select: s,
        distinct: s.parent_station_id
    )
    |> Enum.map(&{&1.name, &1.parent_station_id})
  end

  def mount(%{"id" => disruption_id}, _session, socket) do
    disruption = Disruptions.get_disruption_v2!(disruption_id)

    socket =
      socket
      |> assign(:form_action, :edit)
      |> assign(:title, "edit disruption")
      |> assign(:form, Disruptions.change_disruption_v2(disruption) |> to_form)
      |> assign(:show_service_form?, false)
      |> assign(:show_limit_form?, false)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)

    {:ok, socket}
  end

  def mount(%{} = _params, _session, socket) do
    disruption = DisruptionV2.new()
    form = disruption |> Disruptions.change_disruption_v2() |> to_form()

    socket =
      socket
      |> assign(:form_action, :create)
      |> assign(:http_action, ~p"/disruptionsv2/new")
      |> assign(:title, "create new disruption")
      |> assign(:form, form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)
      |> assign(:show_service_form?, false)
      |> assign(:show_limit_form?, false)

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def handle_event(
        "validate",
        %{"disruption_v2" => disruption_v2_params},
        %Phoenix.LiveView.Socket{} = socket
      ) do
    form =
      socket.assigns.disruption_v2
      |> Disruptions.change_disruption_v2(disruption_v2_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"disruption_v2" => disruption_v2_params}, socket) do
    save_disruption_v2(socket, socket.assigns.form_action, disruption_v2_params)
  end

  def handle_event("add_new_replacement_service", _params, socket) do
    socket = assign(socket, :show_service_form?, true)

    {:noreply, socket}
  end

  def handle_event("cancel_add_new_replacement_service", _params, socket) do
    socket = assign(socket, :show_service_form?, false)

    {:noreply, socket}
  end

  def handle_event(
        "add_limit",
        _,
        %{assigns: %{disruption_v2: %DisruptionV2{id: nil}, form: form}} = socket
      ) do
    case Disruptions.create_disruption_v2(form.params) do
      {:ok, disruption} ->
        {:noreply,
         socket
         |> clear_flash()
         |> apply_action(:edit, %{"id" => disruption.id})
         |> assign(:form_action, :edit)
         |> push_patch(to: ~p"/disruptionsv2/#{disruption.id}/edit")
         |> update(:form, fn %{source: changeset} ->
           changeset
           |> Ecto.Changeset.put_assoc(:limits, [Limits.change_limit(Limit.new())])
           |> to_form()
         end)
         |> assign(:show_limit_form?, true)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:error, "Error when saving disruption!")}
    end
  end

  def handle_event("add_limit", _, socket) do
    socket =
      socket
      |> clear_flash()
      |> update(:form, fn %{source: changeset} ->
        existing_limits = Ecto.Changeset.get_assoc(changeset, :limits)

        changeset
        |> Ecto.Changeset.put_assoc(
          :limits,
          existing_limits ++ [Limits.change_limit(Limit.new())]
        )
        |> to_form()
      end)
      |> assign(:show_limit_form?, true)

    {:noreply, socket}
  end

  def handle_event("cancel_add_limit", _params, socket) do
    socket =
      socket
      |> update(:form, fn %{source: changeset} ->
        limits =
          changeset
          |> Ecto.Changeset.get_assoc(:limits)
          |> Enum.reduce([], fn limit, acc ->
            [Limits.change_limit(limit.data, %{editing?: false}) | acc]
          end)

        changeset |> Ecto.Changeset.put_assoc(:limits, limits) |> to_form()
      end)
      |> assign(:show_limit_form?, false)

    {:noreply, socket}
  end

  def handle_event("edit_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        limits =
          changeset
          |> Ecto.Changeset.get_assoc(:limits)
          |> Enum.reduce(
            [],
            fn
              %{data: %{id: ^parsed_id} = data}, acc ->
                [Limits.change_limit(data, %{editing?: true}) | acc]

              limit, acc ->
                [limit | acc]
            end
          )

        changeset |> Ecto.Changeset.put_assoc(:limits, limits) |> to_form()
      end)

    {:noreply, assign(socket, :show_limit_form?, true)}
  end

  defp save_disruption_v2(socket, action, disruption_v2_params) do
    save_result =
      case action do
        :create ->
          Disruptions.create_disruption_v2(disruption_v2_params)

        :edit ->
          Disruptions.update_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params)

        _ ->
          raise "Unknown action for disruption form: #{action}"
      end

    case save_result do
      {:ok, disruption} ->
        disruption = Arrow.Repo.preload(disruption, limits: [:route, :start_stop, :end_stop])

        {:noreply,
         socket
         |> put_flash(:info, "Disruption saved successfully")
         |> assign(:show_limit_form?, false)
         |> assign(:disruption_v2, disruption)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:error, "Error when saving disruption!")}
    end
  end

  @adjustment_kind_icon_names %{
    blue_line: "blue-line",
    bus: "mode-bus",
    commuter_rail: "mode-commuter-rail",
    green_line: "green-line",
    green_line_b: "green-line-b",
    green_line_c: "green-line-c",
    green_line_d: "green-line-d",
    green_line_e: "green-line-e",
    mattapan_line: "mattapan-line",
    orange_line: "orange-line",
    red_line: "red-line",
    silver_line: "silver-line"
  }

  defp adjustment_kind_icon_path(socket, kind) do
    Phoenix.VerifiedRoutes.static_path(
      socket,
      "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg"
    )
  end

  defp icon_paths(socket) do
    Adjustment.kinds()
    |> Enum.map(&{&1, adjustment_kind_icon_path(socket, &1)})
    |> Enum.into(%{})
    |> Map.put(
      :subway,
      Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-mode-subway-small.svg")
    )
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(title: "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption_v2, Disruptions.get_disruption_v2!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Disruption v2")
    |> assign(:disruption_v2, %DisruptionV2{})
  end

  defp format_day_name(day_name) do
    day_name
    |> String.slice(0..2)
    |> String.capitalize()
  end
end
