defmodule ArrowWeb.EditHastusExportForm do
  @moduledoc false
  use ArrowWeb, :live_component

  import Phoenix.HTML.Form

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Hastus
  alias Arrow.Hastus.Export
  alias Arrow.Hastus.ExportUpload
  alias Arrow.Hastus.ServiceDate
  alias Phoenix.LiveView.UploadEntry

  attr :disruption, DisruptionV2, required: true
  attr :export, Export, required: true
  attr :icon_paths, :map, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div
      class="mt-3 overflow-hidden"
      style="display: none"
      phx-mounted={
        JS.show(transition: {"ease-in duration-300", "max-h-0", "max-h-screen"}, time: 300)
        |> JS.focus()
      }
      phx-remove={
        JS.hide(transition: {"ease-out duration-300", "max-h-screen", "max-h-0"}, time: 300)
      }
    >
      <.simple_form
        :if={@show_upload_form}
        for={@form}
        id="upload-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            add a new service schedule
          </h4>
          <h5>Upload a new HASTUS export</h5>
          <div :for={entry <- @uploads.hastus_export.entries}>
            <progress value={entry.progress} max="100">
              {entry.progress}%
            </progress>
          </div>
          <div class="row">
            <div class="col-lg-3">
              <.button
                disabled={Enum.any?(@uploads.hastus_export.entries)}
                type="button"
                class="btn-primary btn-sm w-100"
                phx-click={JS.dispatch("click", to: "##{@uploads.hastus_export.ref}")}
                target="_blank"
              >
                <.live_file_input upload={@uploads.hastus_export} class="hidden" /> Upload HASTUS .zip
              </.button>
            </div>
            <div class="col-lg-3">
              <.link
                id="cancel_add_hastus_export_button"
                class="btn btn-outline-primary btn-sm w-100"
                patch={~p"/disruptions/#{@disruption.id}"}
              >
                Cancel
              </.link>
            </div>
          </div>
          <div :if={not is_nil(@error)} class="mt-3">
            <p class="alert alert-danger m-0">
              {@error}
            </p>
          </div>
          <div :if={not is_nil(@invalid_export_trips)} class="mt-3">
            <p class="alert alert-danger m-0">
              {get_invalid_trips_error_message(@invalid_export_trips)}
              <.button
                type="button"
                class="alert-danger"
                phx-click="download_invalid_export_trips"
                phx-target={@myself}
              >
                Download list of invalid trips
              </.button>
            </p>
          </div>
        </div>
      </.simple_form>

      <.simple_form
        :if={@show_service_import_form}
        for={@form}
        id="service-import-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <h4 class="text-primary mb-0">
            {if @export.id, do: "edit service schedule", else: "add a new service schedule"}
          </h4>
          <div :if={not is_nil(@error)} class="text-danger">
            {@error}
          </div>
          <.input field={@form[:s3_path]} type="text" class="hidden" />
          <.input field={@form[:disruption_id]} type="text" class="hidden" />
          <.input field={@form[:line_id]} type="text" class="hidden" />
          <.inputs_for :let={f_trip_route_directions} field={@form[:trip_route_directions]}>
            <.input field={f_trip_route_directions[:hastus_route_id]} type="text" class="hidden" />
            <.input field={f_trip_route_directions[:via_variant]} type="text" class="hidden" />
            <.input field={f_trip_route_directions[:avi_code]} type="text" class="hidden" />
            <.input field={f_trip_route_directions[:route_id]} type="text" class="hidden" />
          </.inputs_for>
          <div class="text-success mb-3">
            <strong>
              <i>Successfully imported export {@uploaded_file_name}!</i>
            </strong>
          </div>
          <div class="row mb-3">
            <div class="col-lg-2">
              <strong>route</strong>
            </div>
            <div class="col-lg-10">
              <span
                class="m-icon m-icon-sm mr-1"
                style={"background-image: url('#{line_icon_path(@icon_paths, input_value(@form, :line_id))}');"}
              />
              {format_line_id(input_value(@form, :line_id))} line
            </div>
          </div>
          <.inputs_for :let={f_service} field={@form[:services]}>
            <.inputs_for :let={f_derived_limit} field={f_service[:derived_limits]}>
              <.input field={f_derived_limit[:start_stop_id]} type="text" class="hidden" />
              <.input field={f_derived_limit[:end_stop_id]} type="text" class="hidden" />
            </.inputs_for>
            <.input field={f_service[:name]} type="text" class="hidden" />
            <div class="row mb-3">
              <div class="col-lg-2">
                <strong>service ID</strong>
              </div>
              <div class="col-lg-3">
                {input_value(f_service, :name)}
              </div>
              <div
                :if={
                  input_value(f_service, :import?) in [true, "true"] and
                    input_value(f_service, :derived_limits) == []
                }
                class="col-lg-7 text-sm text-danger"
              >
                *Unable to derive any disruption limits: this service does not contain any trips with non-canonical route patterns.<br />
                Consider deactivating it.
              </div>
            </div>
            <.inputs_for :let={f_date} field={f_service[:service_dates]}>
              <div class="row">
                <div class="col-lg-1"></div>
                <%= if f_date.index == 0 do %>
                  <div class="col-lg-1">
                    <.label for={f_service[:import?].id}>activate?</.label>
                    <.input
                      class="ml-4"
                      field={f_service[:import?]}
                      id={"import-checkbox-#{f_service.index}"}
                      type="checkbox"
                    />
                  </div>
                <% else %>
                  <div class="col-lg-1"></div>
                <% end %>
                <div class="col">
                  <.input
                    field={f_date[:start_date]}
                    type="date"
                    label={if f_date.index == 0, do: "start date", else: ""}
                  />
                </div>
                <div class="col">
                  <.input
                    field={f_date[:end_date]}
                    type="date"
                    label={if f_date.index == 0, do: "end date", else: ""}
                  />
                </div>
                <div
                  :if={Enum.count(f_service[:service_dates].value) > 1}
                  class="col-auto align-self-center mt-3"
                >
                  <.button
                    type="button"
                    phx-click="delete_service_date"
                    phx-value-service_index={f_service.index}
                    phx-value-date_index={f_date.index}
                    phx-target={@myself}
                  >
                    <.icon name="hero-trash-solid" class="bg-primary" />
                  </.button>
                </div>
                <div class="col text-sm py-4 text-danger">
                  {get_service_date_warning(
                    input_value(f_service, :name),
                    input_value(f_date, :start_date),
                    input_value(f_date, :end_date)
                  )}
                </div>
              </div>
            </.inputs_for>
            <div class="row mb-4">
              <div class="col-lg-2"></div>
              <.button
                type="button"
                class="btn btn-primary ml-3 btn-sm"
                value={f_service.index}
                phx-click="add_timeframe"
                phx-target={@myself}
              >
                Add Another Timeframe
              </.button>
            </div>
          </.inputs_for>
          <%= if @confirming_dup_service_ids? do %>
            <div class="text-warning mb-3">
              <strong>
                The HASTUS export that you uploaded includes service IDs that have been previously imported into Arrow.<br />
                Are you sure you would like to continue?
              </strong>
            </div>
            <div class="row no-gutters">
              <div class="col-lg-auto">
                <.button
                  id="accept-duplicate-service-ids-button"
                  type="button"
                  class="btn btn-primary btn-sm mr-2"
                  phx-click="confirm_dup_service_ids"
                  phx-target={@myself}
                >
                  Yes, fix duplicate service IDs in this export for me
                </.button>
              </div>
              <div class="col-lg-auto">
                <.link
                  id="reject-duplicate-service-ids-button"
                  class="btn btn-outline-primary btn-sm"
                  patch={~p"/disruptions/#{@disruption.id}"}
                >
                  No, cancel upload
                </.link>
              </div>
            </div>
          <% else %>
            <div class="row">
              <div class="col-lg-4">
                <.button
                  id="save-export-button"
                  type="submit"
                  class="btn btn-primary btn-sm w-100"
                  phx-target={@myself}
                >
                  Save
                </.button>
              </div>
              <div class="col-lg-3">
                <.link
                  id="cancel_add_hastus_export_button"
                  class="btn btn-outline-primary btn-sm w-100"
                  data-confirm="Are you sure you want to cancel? All changes to this HASTUS export will be lost!"
                  patch={~p"/disruptions/#{@disruption.id}"}
                >
                  Cancel
                </.link>
              </div>
            </div>
          <% end %>
        </div>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{export: %{id: nil}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:show_upload_form, true)
      |> assign(:show_service_import_form, false)
      |> assign(:form, nil)
      |> assign(:error, nil)
      |> assign(:invalid_export_trips, nil)
      |> allow_upload(:hastus_export,
        accept: ~w(.zip),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  def update(assigns, socket) do
    form =
      assigns.export
      |> Hastus.change_export()
      |> to_form()

    filename = assigns.export.s3_path |> String.split("/") |> List.last()

    socket =
      socket
      |> assign(assigns)
      |> assign(:show_upload_form, false)
      |> assign(:show_service_import_form, true)
      |> assign(:form, form)
      |> assign(:uploaded_file_name, filename)
      |> assign(:error, nil)
      |> assign(:confirming_dup_service_ids?, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"_target" => ["hastus_export"]}, socket) do
    socket = socket |> clear_flash() |> assign(error: nil)

    with [entry] <- socket.assigns.uploads.hastus_export.entries,
         [error] <- upload_errors(socket.assigns.uploads.hastus_export, entry) do
      socket =
        socket
        |> cancel_upload(:hastus_export, entry.ref)
        |> assign(error: error_to_string(error))

      {:noreply, socket}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("validate", %{"export" => export_params}, socket) do
    form =
      socket.assigns.export
      |> Hastus.change_export(export_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("add_timeframe", %{"value" => index}, socket) do
    {index, _} = Integer.parse(index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        updated_services =
          changeset
          |> Ecto.Changeset.get_assoc(:services)
          |> update_in([Access.at(index)], fn service ->
            existing_dates = Ecto.Changeset.get_assoc(service, :service_dates)
            Ecto.Changeset.put_change(service, :service_dates, existing_dates ++ [%ServiceDate{}])
          end)

        changeset = Ecto.Changeset.put_assoc(changeset, :services, updated_services)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("delete_service_date", %{"service_index" => service_index, "date_index" => date_index}, socket) do
    {service_index, _} = Integer.parse(service_index)
    {date_index, _} = Integer.parse(date_index)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        updated_services =
          changeset
          |> Ecto.Changeset.get_assoc(:services)
          |> update_in([Access.at(service_index)], fn service ->
            dates =
              service |> Ecto.Changeset.get_assoc(:service_dates) |> List.delete_at(date_index)

            Ecto.Changeset.put_change(service, :service_dates, dates)
          end)

        changeset = Ecto.Changeset.put_assoc(changeset, :services, updated_services)
        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event("save", %{"export" => export_params}, socket) do
    if socket.assigns.export.id do
      update_export(export_params, socket)
    else
      create_export(export_params, socket)
    end
  end

  def handle_event("confirm_dup_service_ids", _params, socket) do
    {:noreply, assign(socket, confirming_dup_service_ids?: false)}
  end

  def handle_event(
        "download_invalid_export_trips",
        _params,
        %{assigns: %{invalid_export_trips: {error, invalid_trips}}} = socket
      ) do
    socket =
      send_download(
        socket,
        get_invalid_trips_file_name(error),
        Enum.join(invalid_trips, "\n"),
        content_type: "text/plain"
      )

    {:noreply, socket}
  end

  def handle_event("download_invalid_export_trips", _params, socket) do
    socket = send_download(socket, "invalid_trips.txt", "", content_type: "text/plain")

    {:noreply, socket}
  end

  defp create_export(export_params, socket) do
    imported_services =
      for {key, value} <- export_params["services"],
          value["import?"] == "true",
          into: %{},
          do: {key, value}

    if imported_services == %{} do
      {:noreply, assign(socket, error: "You must import at least one service")}
    else
      with {:ok, s3_path} <-
             ExportUpload.upload_to_s3(
               socket.assigns.uploaded_file_data,
               socket.assigns.uploaded_file_name,
               socket.assigns.disruption.id
             ),
           {:ok, _} <-
             Hastus.create_export(%{
               export_params
               | "s3_path" => s3_path
             }) do
        {:noreply,
         socket
         |> push_patch(to: "/disruptions/#{socket.assigns.disruption.id}")
         |> put_flash(:info, "HASTUS service schedules imported successfully!")}
      else
        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}

        {:error, _} ->
          {:noreply, assign(socket, error: "Failed to upload export to S3")}
      end
    end
  end

  defp update_export(export_params, socket) do
    imported_services =
      for {key, value} <- export_params["services"],
          value["import?"] == "true",
          into: %{},
          do: {key, value}

    if imported_services == %{} do
      {:noreply, assign(socket, error: "You must import at least one service")}
    else
      export = Hastus.get_export!(socket.assigns.export.id)

      case Hastus.update_export(export, export_params) do
        {:ok, _} ->
          {:noreply,
           socket
           |> push_patch(to: "/disruptions/#{socket.assigns.disruption.id}")
           |> put_flash(:info, "HASTUS service schedules updated successfully!")}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, form: to_form(changeset))}
      end
    end
  end

  defp handle_progress(:hastus_export, %UploadEntry{done?: false}, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:hastus_export, %UploadEntry{client_name: client_name} = entry, socket) do
    socket = socket |> clear_flash() |> assign(error: nil)

    case consume_uploaded_entry(
           socket,
           entry,
           &ExportUpload.extract_data_from_upload(&1, socket.assigns.user_id)
         ) do
      {:error, {_, _} = invalid_export_trips} ->
        {:noreply, assign(socket, invalid_export_trips: invalid_export_trips)}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}

      {:ok, export_data} ->
        form =
          socket.assigns.export
          |> Hastus.change_export(%{
            "services" => export_data.services,
            "trip_route_directions" => export_data.trip_route_directions,
            "line_id" => export_data.line_id,
            "s3_path" => client_name,
            "disruption_id" => socket.assigns.disruption.id
          })
          |> to_form(action: :validate)

        {:noreply,
         assign(socket,
           form: form,
           show_upload_form: false,
           show_service_import_form: true,
           uploaded_file_name: client_name,
           uploaded_file_data: export_data.zip_binary,
           confirming_dup_service_ids?: export_data.dup_service_ids_amended?
         )}
    end
  end

  defp format_line_id(line_id), do: String.replace(line_id, "line-", "")

  defp date_range_outside_service_dates?(_service_id, start_date, end_date)
       when start_date in [nil, ""] or end_date in [nil, ""] do
    false
  end

  defp date_range_outside_service_dates?(service_id, start_date, end_date) do
    active_day_of_weeks =
      start_date
      |> Date.range(end_date)
      |> Enum.map(&Date.day_of_week/1)
      |> Enum.sort()
      |> MapSet.new()

    relevant_day_of_weeks =
      cond do
        String.contains?(service_id, "Saturday") -> MapSet.new([6])
        String.contains?(service_id, "Sunday") -> MapSet.new([7])
        String.contains?(service_id, "Weekday") -> MapSet.new([1, 2, 3, 4, 5])
      end

    not MapSet.subset?(active_day_of_weeks, relevant_day_of_weeks)
  end

  defp get_service_date_warning(_service_id, start_date, end_date) when start_date == "" or end_date == "" do
    ""
  end

  defp get_service_date_warning(service_id, start_date, end_date) when is_binary(start_date) do
    get_service_date_warning(service_id, Date.from_iso8601!(start_date), end_date)
  end

  defp get_service_date_warning(service_id, start_date, end_date) when is_binary(end_date) do
    get_service_date_warning(service_id, start_date, Date.from_iso8601!(end_date))
  end

  defp get_service_date_warning(service_id, start_date, end_date) do
    if date_range_outside_service_dates?(service_id, start_date, end_date) do
      service_part =
        cond do
          String.contains?(service_id, "Saturday") -> "Saturdays"
          String.contains?(service_id, "Sunday") -> "Sundays"
          String.contains?(service_id, "Weekday") -> "weekdays"
        end

      "*The selected dates are not #{service_part}. Are you sure?"
    end
  end

  defp error_to_string(:too_large), do: "File is too large. Maximum size is 8MB"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(_), do: "Upload failed. Please try again or contact an engineer"

  defp get_invalid_trips_file_name(:trips_with_invalid_shapes), do: "trips_with_invalid_shapes.txt"

  defp get_invalid_trips_file_name(:trips_with_invalid_blocks), do: "trips_with_invalid_blocks.txt"

  defp get_invalid_trips_error_message({:trips_with_invalid_shapes, _}), do: "Some trips have invalid or missing shapes."

  defp get_invalid_trips_error_message({:trips_with_invalid_blocks, _}),
    do: "Some trips have invalid or missing block IDs."
end
