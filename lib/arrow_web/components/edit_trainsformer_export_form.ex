defmodule ArrowWeb.EditTrainsformerExportForm do
  @moduledoc false
  require Logger
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Trainsformer
  alias Arrow.Trainsformer.Export
  alias Arrow.Trainsformer.ExportUpload
  alias Arrow.Trainsformer.ServiceDateDayOfWeek
  alias Phoenix.LiveView.UploadEntry

  attr :disruption, DisruptionV2, required: true
  attr :export, Export, required: true
  attr :user_id, :string, required: true

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
          <h5>Upload a new Trainsformer export</h5>

          <.export_alert :for={error <- @errors} error={error} myself={@myself} />

          <div :for={entry <- @uploads.trainsformer_export.entries}>
            <progress value={entry.progress} max="100">
              {entry.progress}%
            </progress>
          </div>
          <div class="row">
            <div class="col-lg-3">
              <.button
                disabled={Enum.any?(@uploads.trainsformer_export.entries)}
                type="button"
                class="btn-primary btn-sm w-100"
                phx-click={JS.dispatch("click", to: "##{@uploads.trainsformer_export.ref}")}
                target="_blank"
              >
                <.live_file_input upload={@uploads.trainsformer_export} class="hidden" />
                Upload Trainsformer .zip
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
        <div class="container-fluid border-2 border-dashed border-primary p-2">
          <.input field={@form[:s3_path]} type="text" class="hidden" />
          <.input field={@form[:disruption_id]} type="text" class="hidden" />

          <.input field={@form[:name]} type="text" class="hidden" />

          <%= if is_nil(assigns.export.id) do %>
            <div class="text-success mb-3">
              <strong>
                <i>Successfully imported export {@uploaded_file_name}!</i>
              </strong>
            </div>
          <% end %>
          <div class="row">
            <div class="col-lg-2">
              <b class="mb-3">Routes</b>
              <%= for route <- @uploaded_file_routes || assigns.export.routes do %>
                <div class="row">
                  <div class="col-lg-1">
                    <span
                      class="m-icon m-icon-sm mr-1"
                      style={"background-image: url('#{Map.get(@icon_paths, :commuter_rail)}');"}
                    />
                  </div>
                  <div class="col-lg-10">
                    <p>{Map.get(route, "route_id") || route.route_id}</p>
                  </div>
                </div>
              <% end %>
              <.errors field={@form[:routes]} always_show />
            </div>
            <div class="col-lg-10">
              <b class="mb-3">Service ID</b>
              <.inputs_for :let={f_service} field={@form[:services]}>
                <div class="row">
                  <div class="col-lg-3 text-sm">
                    <.input field={f_service[:name]} type="text" class="hidden" />
                    {f_service[:name].value}
                  </div>
                  <div class="col-lg-9 text-md">
                    <.inputs_for :let={f_date} field={f_service[:service_dates]}>
                      <input
                        type="hidden"
                        name={Phoenix.HTML.Form.input_name(f_service, :service_dates_sort) <> "[]"}
                        value={f_date.index}
                      />
                      {f_service[:start_date].value}
                      <div class="row">
                        <div class="col">
                          <.input
                            field={f_date[:start_date]}
                            type="date"
                            label="Start Date"
                          />
                        </div>
                        <div class="col">
                          <.input
                            field={f_date[:end_date]}
                            type="date"
                            label="End Date"
                          />
                        </div>

                        <div class="col-lg-4">
                          <div class="row col-form-label">
                            Days of Week
                          </div>
                          <div class="row">
                            <.checkgroup
                              field={f_date[:service_date_days_of_week]}
                              options={
                                for dow <- Arrow.Util.DayOfWeek.get_all_day_names() do
                                  {dow |> :erlang.atom_to_binary() |> String.capitalize(),
                                   dow |> :erlang.atom_to_binary()}
                                end
                              }
                              value={
                                if Ecto.assoc_loaded?(f_date[:service_date_days_of_week].value) do
                                  for day <- f_date[:service_date_days_of_week].value, reduce: [] do
                                    acc ->
                                      case day do
                                        %ServiceDateDayOfWeek{day_name: day_name} ->
                                          [Atom.to_string(day_name) | acc]

                                        %Ecto.Changeset{action: action} = changeset
                                        when action not in [:delete, :replace] ->
                                          day_name =
                                            changeset
                                            |> Ecto.Changeset.get_field(:day_name)
                                            |> Atom.to_string()

                                          [day_name | acc]

                                        str when is_binary(str) ->
                                          [str | acc]

                                        _ ->
                                          acc
                                      end
                                  end
                                else
                                  []
                                end
                              }
                            />
                          </div>
                        </div>
                        <div class="col">
                          <label class="cursor-pointer hover:opacity-140">
                            <.icon name="hero-trash-solid" class="bg-primary" />
                            <input
                              type="checkbox"
                              name={Phoenix.HTML.Form.input_name(f_service, :service_dates_drop) <> "[]"}
                              class="hidden"
                              value={f_date.index}
                            />
                          </label>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col ml-10"></div>
                        <div
                          :if={Enum.count(f_service[:service_dates].value) > 1}
                          class="col-auto align-self-center mt-3"
                        >
                        </div>
                      </div>
                    </.inputs_for>
                  </div>
                </div>

                <div class="row mt-3">
                  <div class="col-9" />
                  <label class="btn h-15 w-15 btn-primary btn-sm">
                    Add Another Timeframe
                    <input
                      type="checkbox"
                      name={Phoenix.HTML.Form.input_name(f_service, :service_dates_sort) <> "[]"}
                      class="hidden"
                      value="new"
                    />
                  </label>
                </div>
              </.inputs_for>
              <.errors field={@form[:services]} always_show />
            </div>
          </div>

          <.export_alert :for={error <- @errors} error={error} myself={@myself} />

          <div class="row">
            <div class="col-lg-4">
              <.button
                id="save-export-button"
                type="submit"
                class="btn btn-primary btn-sm w-100"
                phx-submit="save"
                phx-target={@myself}
              >
                Save
              </.button>
            </div>
            <div class="col-lg-3">
              <.link
                id="cancel_add_trainsformer_export_button"
                class="btn btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this Trainsformer export will be lost!"
                patch={~p"/disruptions/#{@disruption.id}"}
              >
                Cancel
              </.link>
            </div>
          </div>
        </div>
      </.simple_form>
    </div>
    """
  end

  attr :error, :any,
    required: true,
    doc:
      "A `Arrow.Trainsformer.ExportUpload.validation_message()` tuple used to render an `<.alert>`"

  attr :myself, Phoenix.Component.CID, doc: "The component instance to send events to"

  def export_alert(%{error: {type, {key, {message, metadata}}}} = assigns) do
    assigns =
      assigns
      |> assign(
        type: type,
        key: key,
        message: message,
        metadata: metadata
      )
      |> Map.drop([:error])

    alert(assigns)
  end

  attr :type, :atom, required: true, values: [:error, :warning], doc: "The severity of the alert"
  attr :message, :string, required: true, doc: "Text used as the summary of the alert"
  attr :metadata, :list, default: [], doc: "A Keyword list used to add extra content to the alert"
  attr :key, :any, doc: "Any identifier that can be used to differentiate specific alerts"

  attr :myself, Phoenix.Component.CID, doc: "The component instance to send events to"

  defp alert(assigns) do
    ~H"""
    <ArrowWeb.DisruptionComponents.upload_alert type={@type}>
      <strong>{@message}</strong>

      <.alert_content
        :for={{key, value} <- @metadata}
        key={key}
        value={value}
        alert_key={@key}
        myself={@myself}
      />
    </ArrowWeb.DisruptionComponents.upload_alert>
    """
  end

  attr :alert_key, :any, doc: "Any identifier that can be used to differentiate specific alerts"

  attr :key, :atom,
    required: true,
    doc: "Atom identifying how the associated data attribute should be rendered"

  attr :value, :any, doc: "Data for rendering"
  attr :myself, Phoenix.Component.CID, doc: "The component instance to send events to"

  defp alert_content(%{alert_key: :stop_id_not_in_gtfs, key: :items} = assigns) do
    ~H"""
    <.button
      type="button"
      class="alert-info d-block mt-2"
      phx-click="download_invalid_export_stops"
      phx-target={@myself}
    >
      Download list of invalid stops
    </.button>
    """
  end

  defp alert_content(%{alert_key: :invalid_stop_times, key: :rows} = assigns) do
    ~H"""
    <.button
      type="button"
      class="alert-info d-block mt-2"
      phx-click="download_invalid_stop_times"
      phx-target={@myself}
    >
      Download list of invalid stop times
    </.button>
    """
  end

  defp alert_content(%{key: :items} = assigns) do
    ~H"""
    <ul>
      <li :for={item <- @value}>{item}</li>
    </ul>
    """
  end

  defp alert_content(%{key: :message} = assigns), do: ~H"<pre>{@value}</pre>"
  defp alert_content(%{key: :suggestion} = assigns), do: ~H"<p>{@value}</p>"

  defp alert_content(assigns), do: ~H""

  @impl true
  def update(%{export: %{id: nil}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:errors, [])
      |> assign(:show_upload_form, true)
      |> assign(:show_service_import_form, false)
      |> assign(:form, nil)
      |> allow_upload(:trainsformer_export,
        accept: ~w(.zip),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  def update(assigns, socket) do
    form =
      assigns.export
      |> Trainsformer.change_export()
      |> to_form()

    socket =
      socket
      |> assign(assigns)
      |> assign(:errors, [])
      |> assign(:show_upload_form, false)
      |> assign(:show_service_import_form, true)
      |> assign(:form, form)
      |> assign(:uploaded_file_name, nil)
      |> assign(:uploaded_file_routes, nil)
      |> allow_upload(:trainsformer_export,
        accept: ~w(.zip),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"export" => export_params}, socket) do
    form =
      socket.assigns.export
      |> Trainsformer.change_export(export_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"export" => export_params}, socket) do
    if socket.assigns.export.id do
      update_export(export_params, socket)
    else
      create_export(export_params, socket)
    end
  end

  def handle_event(
        "download_invalid_export_stops",
        _params,
        %{assigns: %{errors: errors}} = socket
      ) do
    stops =
      Enum.find_value(errors, fn
        {_, {:stop_id_not_in_gtfs, {_, opts}}} -> opts[:items]
        _ -> false
      end)

    socket =
      send_download(
        socket,
        "trips_with_stops_not_in_gtfs.txt",
        Enum.join(stops, "\n"),
        content_type: "text/plain"
      )

    {:noreply, socket}
  end

  def handle_event(
        "download_invalid_stop_times",
        _params,
        %{assigns: %{errors: errors}} = socket
      ) do
    stop_times =
      Enum.find_value(errors, fn
        {_, {:invalid_stop_times, {_, opts}}} -> opts[:rows]
        _ -> false
      end)

    stop_times_lines =
      Enum.map(stop_times, fn stop_time ->
        "trip_id: #{stop_time[:trip_id]}, stop_id: #{stop_time[:stop_id]}, stop_sequence: #{stop_time[:stop_sequence]}, arrival_time: #{stop_time[:arrival_time]}, departure_time: #{stop_time[:departure_time]}"
      end)

    socket =
      send_download(
        socket,
        "trips_with_invalid_stop_order.txt",
        Enum.join(stop_times_lines, "\n"),
        content_type: "text/plain"
      )

    {:noreply, socket}
  end

  defp handle_progress(:trainsformer_export, %UploadEntry{done?: false}, socket) do
    {:noreply, socket}
  end

  defp handle_progress(
         :trainsformer_export,
         %UploadEntry{client_name: client_name} = entry,
         socket
       ) do
    socket = socket |> clear_flash() |> assign(errors: [])

    case consume_uploaded_entry(
           socket,
           entry,
           &ExportUpload.extract_data_from_upload(&1)
         ) do
      {:ok, export_data} ->
        form =
          socket.assigns.export
          |> Trainsformer.change_export(%{
            "s3_path" => client_name,
            "disruption_id" => socket.assigns.disruption.id,
            "services" => export_data.services,
            "routes" => export_data.routes
          })
          |> to_form(action: :validate)

        {:noreply,
         assign(socket,
           form: form,
           show_upload_form: false,
           show_service_import_form: true,
           uploaded_file_name: client_name,
           uploaded_file_data: export_data.zip_binary,
           uploaded_file_routes: export_data.routes,
           uploaded_file_services: export_data.services,
           errors: export_data.warnings
         )}

      {:error, errors_and_warnings} ->
        {:noreply, assign(socket, errors: errors_and_warnings)}
    end
  end

  defp update_export(export_params, socket) do
    export = Trainsformer.get_export!(socket.assigns.export.id)

    case Trainsformer.update_export(export, export_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> push_patch(to: "/disruptions/#{socket.assigns.disruption.id}")
         |> put_flash(:info, "Trainsformer service schedules updated successfully!")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp create_export(export_params, socket) do
    export_params = Map.put(export_params, "routes", socket.assigns.uploaded_file_routes)

    with {:ok, s3_path} <-
           ExportUpload.upload_to_s3(
             socket.assigns.uploaded_file_data,
             socket.assigns.uploaded_file_name,
             socket.assigns.disruption.id
           ),
         {:ok, _} <-
           Trainsformer.create_export(%{
             export_params
             | "s3_path" => s3_path,
               "name" => socket.assigns.uploaded_file_name
           }) do
      {:noreply,
       socket
       |> push_patch(to: "/disruptions/#{socket.assigns.disruption.id}")
       |> put_flash(:info, "Trainsformer service schedules imported successfully!")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, _} ->
        {:noreply,
         socket
         |> update(
           :errors,
           &[{:error, {:s3_upload_failed, {"Failed to upload export to S3", []}}} | &1]
         )}
    end
  end
end
