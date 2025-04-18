defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view
  import Phoenix.HTML.Form

  alias Arrow.{Adjustment, Disruptions, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit, ReplacementService}
  alias Arrow.Hastus.Export
  alias Arrow.Limits.LimitDayOfWeek

  @spec mode_labels :: list(tuple())
  def mode_labels,
    do: [
      {"Subway/Light Rail", :subway},
      {"Commuter Rail", :commuter_rail},
      {"Bus", :bus},
      {"Silver Line", :silver_line}
    ]

  attr :id, :string
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :disruption_v2, DisruptionV2, required: true
  attr :icon_paths, :map, required: true
  attr :errors, :map, default: %{}
  attr :limit_in_form, :any
  attr :replacement_service_in_form, :any
  attr :hastus_export_in_form, :any
  attr :user_id, :string

  def disruption_form(assigns) do
    ~H"""
    <div>
      <.simple_form for={@form} id="disruption_v2-form" phx-submit={@action} phx-change="validate">
        <div class="flex flex-row">
          <fieldset class="w-50">
            <legend>Title</legend>
            <.input field={@form[:title]} type="text" placeholder="Add text" />
          </fieldset>
          <fieldset class="w-50 ml-20">
            <legend>Approval Status</legend>
            <div class="form-check">
              <input
                name={@form[:is_active].name}
                id="status-approved"
                class="form-check-input"
                type="radio"
                checked={normalize_value("checkbox", input_value(@form, :is_active))}
                value="true"
                disabled={@action == :create}
              />
              <label for="status-approved" class="form-check-label">
                Approved
              </label>
            </div>
            <div class="form-check">
              <input
                name={@form[:is_active].name}
                id="status-pending"
                class="form-check-input"
                type="radio"
                checked={!normalize_value("checkbox", input_value(@form, :is_active))}
                value="false"
              />
              <label for="status-pending" class="form-check-label">
                Pending
              </label>
            </div>
          </fieldset>
        </div>
        <fieldset>
          <legend>Mode</legend>
          <div :for={{{mode, value}, idx} <- Enum.with_index(mode_labels())} class="form-check">
            <input
              name={@form[:mode].name}
              id={"#{@form[:mode].id}-#{idx}"}
              class="form-check-input"
              type="radio"
              checked={input_value(@form, :mode) == value}
              disabled={value != :subway}
              value={value}
            />
            <label for={"#{@form[:mode].id}-#{idx}"} class="form-check-label">
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
      </.simple_form>

      <.live_component
        id="limit_section"
        module={ArrowWeb.LimitSection}
        limit={@limit_in_form}
        icon_paths={@icon_paths}
        disruption={@disruption_v2}
        disabled?={not is_nil(@hastus_export_in_form) or not is_nil(@replacement_service_in_form)}
      />

      <.live_component
        id="hastus_export_section"
        module={ArrowWeb.HastusExportSection}
        icon_paths={@icon_paths}
        hastus_export={@hastus_export_in_form}
        disruption={@disruption_v2}
        user_id={@user_id}
        disabled?={not is_nil(@limit_in_form) or not is_nil(@replacement_service_in_form)}
      />

      <.live_component
        id="replacement_service_section"
        module={ArrowWeb.ReplacementServiceSection}
        replacement_service={@replacement_service_in_form}
        disruption={@disruption_v2}
        icon_paths={@icon_paths}
        disabled?={not is_nil(@hastus_export_in_form) or not is_nil(@limit_in_form)}
      />

      <div class="d-flex justify-content-center py-4 mb-5">
        <div class="w-25 mr-2">
          <.button
            type="submit"
            disabled={not Enum.empty?(@errors)}
            class="btn btn-primary w-100"
            form="disruption_v2-form"
          >
            save disruption
          </.button>
        </div>
        <div class="w-25 mr-2">
          <.link_button
            href={~p"/disruptionsv2"}
            class="btn-outline-primary w-100"
            data-confirm="Are you sure you want to cancel? All changes will be lost!"
          >
            cancel
          </.link_button>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"id" => disruption_id}, session, socket) do
    disruption = Disruptions.get_disruption_v2!(disruption_id)

    socket =
      socket
      |> assign(:form_action, :edit)
      |> assign(:title, "edit disruption")
      |> assign(:form, Disruptions.change_disruption_v2(disruption) |> to_form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)
      |> assign(:limit_in_form, nil)
      |> assign(:replacement_service_in_form, nil)
      |> assign(:hastus_export_in_form, nil)
      |> assign(:user_id, session["current_user"].id)

    {:ok, socket}
  end

  @impl true
  def mount(%{} = _params, session, socket) do
    disruption = DisruptionV2.new()

    form =
      disruption
      |> Disruptions.change_disruption_v2(%{is_active: false, mode: :subway})
      |> to_form()

    socket =
      socket
      |> assign(:form_action, :create)
      |> assign(:http_action, ~p"/disruptionsv2/new")
      |> assign(:title, "create new disruption")
      |> assign(:form, form)
      |> assign(:errors, %{})
      |> assign(:icon_paths, icon_paths(socket))
      |> assign(:disruption_v2, disruption)
      |> assign(:limit_in_form, nil)
      |> assign(:replacement_service_in_form, nil)
      |> assign(:hastus_export_in_form, nil)
      |> assign(:user_id, session["current_user"].id)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
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

  def handle_event("create", %{"disruption_v2" => disruption_v2_params}, socket) do
    case Disruptions.create_disruption_v2(disruption_v2_params) do
      {:ok, disruption} ->
        {:noreply,
         socket
         |> clear_flash()
         |> assign(:page_title, "Edit Disruption v2")
         |> assign(:disruption_v2, disruption)
         |> assign(:form_action, :edit)
         |> assign(:title, "edit disruption")
         |> push_patch(to: ~p"/disruptionsv2/#{disruption.id}/edit")
         |> put_flash(:info, "Disruption created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:error, "Error when saving disruption!")}
    end
  end

  def handle_event("edit", %{"disruption_v2" => disruption_v2_params}, socket) do
    case Disruptions.update_disruption_v2(socket.assigns.disruption_v2, disruption_v2_params) do
      {:ok, disruption} ->
        {:noreply,
         socket
         |> put_flash(:info, "Disruption updated successfully")
         |> assign(:disruption_v2, disruption)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(:error, "Error when saving disruption!")}
    end
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
         |> assign(:page_title, "Edit Disruption v2")
         |> assign(:disruption_v2, disruption)
         |> assign(:form_action, :edit)
         |> assign(:title, "edit disruption")
         |> push_patch(to: ~p"/disruptionsv2/#{disruption.id}/edit")
         |> assign(:limit_in_form, Limit.new())
         |> assign(:replacement_service_in_form, nil)
         |> assign(:hastus_export_in_form, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(
           :errors,
           {"Error when saving disruption!",
            ["Please define the disruption before adding a limit"]}
         )}
    end
  end

  def handle_event("add_limit", _, socket) do
    socket =
      socket
      |> clear_flash()
      |> assign(:limit_in_form, Limit.new())

    {:noreply, socket}
  end

  def handle_event("edit_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)
    limit = Arrow.Limits.get_limit!(parsed_id)
    day_of_weeks = Enum.map(limit.limit_day_of_weeks, &LimitDayOfWeek.set_all_day_default/1)

    {:noreply, assign(socket, :limit_in_form, %{limit | limit_day_of_weeks: day_of_weeks})}
  end

  def handle_event("duplicate_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)

    duplicated_limit =
      parsed_id
      |> Limits.get_limit!()
      |> Map.from_struct()
      |> Map.drop([:id, :inserted_at, :updated_at, :__meta__])

    duplicated_day_of_weeks =
      duplicated_limit
      |> Map.get(:limit_day_of_weeks)
      |> Enum.map(fn day_of_week ->
        day =
          day_of_week
          |> Map.from_struct()
          |> Map.drop([:id, :inserted_at, :updated_at, :limit_id, :__meta__, :limit])
          |> LimitDayOfWeek.set_all_day_default()

        struct(LimitDayOfWeek, day)
      end)

    {:noreply,
     assign(socket,
       limit_in_form:
         Limit.new(%{
           duplicated_limit
           | limit_day_of_weeks: duplicated_day_of_weeks
         })
     )}
  end

  def handle_event(
        "add_replacement_service",
        _,
        %{assigns: %{disruption_v2: %DisruptionV2{id: nil}, form: form}} = socket
      ) do
    case Disruptions.create_disruption_v2(form.params) do
      {:ok, disruption} ->
        {:noreply,
         socket
         |> clear_flash()
         |> assign(:page_title, "Edit Disruption v2")
         |> assign(:disruption_v2, disruption)
         |> assign(:form_action, :edit)
         |> assign(:title, "edit disruption")
         |> push_patch(to: ~p"/disruptionsv2/#{disruption.id}/edit")
         |> assign(:limit_in_form, nil)
         |> assign(:replacement_service_in_form, %ReplacementService{})
         |> assign(:hastus_export_in_form, nil)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(form: to_form(changeset))
         |> put_flash(
           :errors,
           {"Error when saving disruption!",
            ["Please define the disruption before adding replacement service"]}
         )}
    end
  end

  def handle_event("add_replacement_service", _, socket) do
    socket =
      socket
      |> clear_flash()
      |> assign(:replacement_service_in_form, %ReplacementService{})

    {:noreply, socket}
  end

  def handle_event(
        "edit_replacement_service",
        %{"replacement_service" => replacement_service_id},
        socket
      ) do
    {parsed_id, _} = Integer.parse(replacement_service_id)
    replacement_service = Disruptions.get_replacement_service!(parsed_id)

    {:noreply, assign(socket, :replacement_service_in_form, replacement_service)}
  end

  def handle_event("upload_hastus_export", _, socket) do
    socket =
      socket
      |> clear_flash()
      |> assign(:hastus_export_in_form, %Export{services: []})

    {:noreply, socket}
  end

  @impl true
  def handle_info(:update_disruption, socket) do
    disruption = Disruptions.get_disruption_v2!(socket.assigns.disruption_v2.id)
    form = disruption |> Disruptions.change_disruption_v2() |> to_form()

    {:noreply,
     socket
     |> assign(
       limit_in_form: nil,
       replacement_service_in_form: nil,
       hastus_export_in_form: nil,
       disruption_v2: disruption,
       form: form
     )}
  end

  def handle_info({:put_flash, kind, message}, socket) do
    {:noreply, put_flash(socket, kind, message)}
  end

  def handle_info(:cancel_limit_form, socket) do
    {:noreply, assign(socket, limit_in_form: nil)}
  end

  def handle_info(:cancel_replacement_service_form, socket) do
    {:noreply, assign(socket, replacement_service_in_form: nil)}
  end

  def handle_info(:cancel_hastus_export_form, socket) do
    {:noreply, assign(socket, hastus_export_in_form: nil)}
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
    |> Map.put(
      :bus_outline,
      Phoenix.VerifiedRoutes.static_path(socket, "/images/icon-bus-outline-small.svg")
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
