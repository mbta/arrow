defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  import Phoenix.HTML.Form

  alias Arrow.{Adjustment, Disruptions, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit}

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

  attr :id, :string
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :disruption_v2, DisruptionV2, required: true
  attr :icon_paths, :map, required: true
  attr :errors, :map, default: %{}
  attr :show_limit_form?, :boolean
  attr :adding_new_service?, :boolean

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
        <fieldset></fieldset>
        <.limit_form_section
          form={@form}
          show_limit_form?={@show_limit_form?}
          existing_limits={@disruption_v2.limits}
        />

        <.replacement_service_section form={@form} adding_new_service?={@adding_new_service?} />

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

  attr :adding_new_service?, :boolean, required: true
  attr :form, :any, required: true

  defp replacement_service_section(assigns) do
    ~H"""
    <h3>Replacement Service</h3>
    <div>
      <span :if={!@adding_new_service?} class="text-primary">
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
      <div :if={@adding_new_service?} class="border-2 border-dashed border-primary p-2">
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
  attr :existing_limits, :any, default: []
  attr :show_limit_form?, :boolean, required: true

  defp limit_form_section(assigns) do
    ~H"""
    <h3>Limits</h3>
    <.link_button :if={!@show_limit_form?} class="btn-link" phx-click="add_limit">
      <.icon name="hero-plus" /> <span>add limit component</span>
    </.link_button>
    <%!-- <.inputs_for :let={f_limit} :if={@show_limit_form?} field={@form[:limits]}> --%>
    <.inputs_for :let={f_limit} field={@form[:limits]}>
      <div :if={is_nil(f_limit[:id].value)} class="border-2 border-dashed border-primary p-2">
        <h4 class="text-primary">add new disruption limit</h4>
        <div class="row">
          <div class="col-lg-3">
            <.input
              class="h-100"
              field={f_limit[:route_id]}
              type="select"
              label="route"
              prompt="Choose a route"
              options={["Red Line"]}
            />
          </div>
          <.stop_input
            field={f_limit[:display_start_stop_id]}
            stop_or_gtfs_stop={f_limit[:start_stop].value}
            label="start stop"
          /> to
          <.stop_input
            field={f_limit[:display_end_stop_id]}
            stop_or_gtfs_stop={f_limit[:end_stop].value}
            label="end stop"
          />
        </div>
        <div class="row">
          <.input class="col-lg-3" field={f_limit[:start_date]} type="date" label="start date" />
          <.input class="col-lg-3" field={f_limit[:end_date]} type="date" label="end date" />
        </div>
        <div class="row">
          <div class="col-lg-3">
            <.button class="btn btn-primary w-100" phx-click="save_limit">
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

  def mount(%{"id" => disruption_id}, _session, socket) do
    disruption = Disruptions.get_disruption_v2!(disruption_id)

    socket =
      socket
      |> assign(:form_action, :edit)
      |> assign(:title, "edit disruption")
      |> assign(:form, Disruptions.change_disruption_v2(disruption) |> to_form)
      |> assign(:adding_new_service?, false)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)
      |> assign(:show_limit_form?, false)

    {:ok, socket}
  end

  def mount(%{} = _params, _session, socket) do
    disruption = %DisruptionV2{limits: []}
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
      |> assign(:show_limit_form?, false)
      |> assign(:adding_new_service?, false)

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
    socket = assign(socket, :adding_new_service?, true)

    {:noreply, socket}
  end

  def handle_event("cancel_add_new_replacement_service", _params, socket) do
    socket = assign(socket, :adding_new_service?, false)

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
         |> apply_action(:edit, %{"id" => disruption.id})
         |> assign(show_limit_form?: true)
         |> push_patch(to: ~p"/disruptionsv2/#{disruption.id}/edit")
         |> clear_flash()
         |> update(:form, fn %{source: changeset} ->
           empty_limit = Limits.change_limit(%Limit{})
           changeset |> Ecto.Changeset.put_assoc(:limits, [empty_limit]) |> to_form()
         end)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:error, "Error when saving disruption!")}
    end
  end

  def handle_event("add_limit", _, socket) do
    socket =
      assign(socket, show_limit_form?: true)
      |> clear_flash()
      |> update(:form, fn %{source: changeset} ->
        empty_limit = Limits.change_limit(%Limit{})

        changeset
        |> Ecto.Changeset.put_assoc(:limits, [empty_limit])
        |> to_form()
      end)

    {:noreply, socket}
  end

  def handle_event("save_limit", _params, socket) do
    socket = assign(socket, :show_limit_form?, false)

    {:noreply, socket}
  end

  def handle_event("cancel_add_limit", _params, socket) do
    socket = assign(socket, :show_limit_form?, false)

    {:noreply, socket}
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
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Disruption saved successfully")}

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
end
