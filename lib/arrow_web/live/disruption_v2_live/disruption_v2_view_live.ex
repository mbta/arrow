defmodule ArrowWeb.DisruptionV2ViewLive do
  use ArrowWeb, :live_view

  alias Arrow.{Adjustment, Disruptions, Limits}
  alias Arrow.Disruptions.{DisruptionV2, Limit, ReplacementService}
  alias Arrow.Hastus
  alias Arrow.Hastus.Export
  alias Arrow.Limits.LimitDayOfWeek
  alias ArrowWeb.DisruptionComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.navbar page={~p"/disruptions/new"} />

    <hr />

    <.header>
      {@title}
    </.header>

    <hr />

    <h2>Disruption</h2>
    <div>
      <%= if @disruption == @editing do %>
        <.live_component
          id="disruption_form"
          module={ArrowWeb.EditDisruptionForm}
          icon_paths={@icon_paths}
          disruption={@editing}
        />
      <% else %>
        <DisruptionComponents.view_disruption
          disruption={@disruption}
          icon_paths={@icon_paths}
          editing={@editing}
        />
      <% end %>
    </div>
    <!-- #TODO: Don't show when creating new disruption -->
    <DisruptionComponents.view_limits
      disruption={@disruption}
      icon_paths={@icon_paths}
      editing={@editing}
    />

    <DisruptionComponents.view_hastus_service_schedules
      disruption={@disruption}
      icon_paths={@icon_paths}
      editing={@editing}
      user_id={@user_id}
    />

    <%!-- <.live_component
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
      /> --%>
    """
  end

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(:icon_paths, icon_paths(socket))
     |> assign(:user_id, session["current_user"].id)}
  end

  # @impl true
  # def mount(_params, session, socket) do
  #   disruption = DisruptionV2.new()

  #   form =
  #     disruption
  #     |> Disruptions.change_disruption_v2(%{is_active: false, mode: :subway})
  #     |> to_form()

  #   socket =
  #     socket
  #     |> assign(:form_action, :create)
  #     |> assign(:title, "create new disruption")
  #     |> assign(:form, form)
  #     |> assign(:errors, %{})
  #     |> assign(:icon_paths, icon_paths(socket))
  #     |> assign(:disruption_v2, disruption)
  #     |> assign(:editing, disruption)
  #     |> assign(:user_id, session["current_user"].id)

  #   {:ok, socket}
  # end

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
         |> push_patch(to: ~p"/disruptions/#{disruption.id}/edit")
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
         |> push_patch(to: ~p"/disruptions/#{disruption.id}/edit")
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
         |> push_patch(to: ~p"/disruptions/#{disruption.id}/edit")
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

  def handle_event("delete_limit", %{"limit" => limit_id}, socket) do
    {parsed_id, _} = Integer.parse(limit_id)
    limit = Limits.get_limit!(parsed_id)

    case Limits.delete_limit(limit) do
      {:ok, _} ->
        disruption = %{
          socket.assigns.disruption
          | limits: Enum.reject(socket.assigns.disruption.limits, &(&1.id == parsed_id))
        }

        {:noreply,
         socket
         |> assign(:disruption, disruption)
         |> put_flash(:info, "Limit deleted successfully")}

      {:error, %Ecto.Changeset{} = _changeset} ->
        {:noreply, socket |> put_flash(:error, "Error when deleting limit!")}
    end
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

  defp apply_action(socket, :show, %{"id" => id}) do
    socket
    |> assign(:page_title, "Show Disruption v2")
    |> assign(:title, "view disruption")
    |> assign(:disruption, Disruptions.get_disruption_v2!(id))
    |> assign(:editing, false)
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, disruption)
  end

  defp apply_action(socket, :new, _params) do
    disruption = %DisruptionV2{}

    socket
    |> assign(:page_title, "New Disruption v2")
    |> assign(:title, "create disruption")
    |> assign(:disruption, disruption)
    |> assign(:editing, disruption)
  end

  defp apply_action(socket, :new_limit, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, Limit.new(disruption_id: disruption.id))
  end

  defp apply_action(socket, :edit_limit, %{"id" => id, "limit_id" => limit_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    limit = Limits.get_limit!(limit_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, limit)
  end

  defp apply_action(socket, :duplicate_limit, %{"id" => id, "limit_id" => limit_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    limit = Limits.get_limit!(limit_id) |> Map.put(:id, nil)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, limit)
  end

  defp apply_action(socket, :new_hastus_export, %{"id" => id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    hastus_export = %Export{services: []}

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, hastus_export)
  end

  defp apply_action(socket, :edit_hastus_export, %{"id" => id, "export_id" => export_id}) do
    disruption = Disruptions.get_disruption_v2!(id)
    hastus_export = Hastus.get_export!(export_id)

    socket
    |> assign(:title, "edit disruption")
    |> assign(:page_title, "Edit Disruption v2")
    |> assign(:disruption, disruption)
    |> assign(:editing, hastus_export)
  end
end
