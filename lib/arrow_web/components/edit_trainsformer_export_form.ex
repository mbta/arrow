defmodule ArrowWeb.EditTrainsformerExportForm do
  @moduledoc false
  require Logger
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Trainsformer
  alias Arrow.Trainsformer.Export
  alias Arrow.Trainsformer.ExportUpload
  alias Arrow.Trainsformer.ServiceDate
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
          <div :if={not is_nil(@invalid_export_stops)} class="d-inline-block p-20 alert alert-danger">
            Some stops are not present in GTFS!
            <.button
              type="button"
              class="alert-info d-block"
              phx-click="download_invalid_export_stops"
              phx-target={@myself}
            >
              Download list of invalid stops
            </.button>
          </div>
          <div :if={not is_nil(@invalid_stop_times)} class="d-inline-block p-20 alert alert-danger">
            Some stop times are out of order!
            <.button
              type="button"
              class="alert-info d-block"
              phx-click="download_invalid_stop_times"
              phx-target={@myself}
            >
              Download list of invalid stop times
            </.button>
          </div>
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
          <div :if={not is_nil(@error)} class="text-danger">
            {@error}
          </div>

          <.input field={@form[:s3_path]} type="text" class="hidden" />
          <.input field={@form[:disruption_id]} type="text" class="hidden" />

          <.input field={@form[:name]} type="text" class="hidden" />

          <div class="text-success mb-3">
            <strong>
              <i>Successfully imported export {@uploaded_file_name}!</i>
            </strong>
          </div>
          <div class="row">
            <div class="col-lg-2">
              <b class="mb-3">Routes</b>
              <%= for route <- @uploaded_file_routes do %>
                <div class="row">
                  <div class="col-lg-1">
                    <span
                      class="m-icon m-icon-sm mr-1"
                      style={"background-image: url('#{Map.get(@icon_paths, :commuter_rail)}');"}
                    />
                  </div>
                  <div class="col-lg-10">
                    <p>{route["route_id"]}</p>
                  </div>
                </div>
              <% end %>
            </div>
            <div class="col-lg-10">
              <b class="mb-3">Services</b>
              <.inputs_for :let={f_service} field={@form[:services]}>
                <div class="row">
                  <div class="col-lg-4">
                    <.input field={f_service[:name]} type="text" class="hidden" />
                    {f_service[:name].value}
                  </div>
                  <div class="col-lg-6">
                    <.inputs_for :let={f_date} field={f_service[:service_dates]}>
                      {f_service[:start_date].value}
                      <div class="row">
                        <div class="col-lg-1"></div>
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
                      </div>
                      <div class="row">
                        <div class="col-lg-4 ml-12">
                          <span
                            :for={
                              dow <-
                                Enum.map(
                                  1..7,
                                  &Arrow.Limits.LimitDayOfWeek.day_name(&1)
                                )
                            }
                            class="text-gray-400"
                          >
                            {format_day_name_short(dow)}
                          </span>
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
                      </div>
                    </.inputs_for>
                  </div>
                  <div class="col-lg-2">
                    <.button
                      type="button"
                      class="btn btn-primary ml-3 btn-sm"
                      value={f_service.index}
                      phx-click="add_service_date"
                      phx-target={@myself}
                    >
                      Add Another Timeframe
                    </.button>
                  </div>
                </div>
              </.inputs_for>
            </div>
          </div>

          <div :if={@one_of_north_south_stations == :both} class="text-warning mb-3">
            Warning: export contains trips serving North and South Station.
          </div>

          <div :if={@one_of_north_south_stations == :neither} class="text-warning mb-3">
            Warning: export does not contain trips serving North or South Station.
          </div>

          <div :if={not Enum.empty?(@missing_routes)} class="text-warning mb-3">
            Warning: Not all northside or southside routes are present. Missing routes:
            <ul>
              <li :for={route_id <- @missing_routes}>{route_id}</li>
            </ul>
          </div>

          <div :if={not Enum.empty?(@invalid_routes)} class="text-warning mb-3">
            Warning: multiple routes not north or southside:
            <ul>
              <li :for={route_id <- @invalid_routes}>{route_id}</li>
            </ul>
          </div>

          <div :if={not Enum.empty?(@trips_missing_transfers)} class="text-warning mb-3">
            Warning: some train trips that do not serve North Station, South Station, or Foxboro lack transfers.
            <ul>
              <li :for={trip_id <- @trips_missing_transfers}>{trip_id}</li>
            </ul>
          </div>

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

  @impl true
  def update(%{export: %{id: nil}} = assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign(:show_upload_form, true)
      |> assign(:show_service_import_form, false)
      |> assign(:form, nil)
      |> assign(:invalid_export_stops, nil)
      |> assign(:invalid_stop_times, nil)
      |> assign(:one_of_north_south_stations, :ok)
      |> assign(:missing_routes, nil)
      |> assign(:invalid_routes, nil)
      |> assign(:trips_missing_transfers, nil)
      |> allow_upload(:trainsformer_export,
        accept: ~w(.zip),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"export" => export_params}, socket) do
    if socket.assigns.export.id do
      # Update to be implemented
      {:noreply, socket}
    else
      create_export(export_params, socket)
    end
  end

  def handle_event(
        "download_invalid_export_stops",
        _params,
        %{assigns: %{invalid_export_stops: stops}} = socket
      ) do
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
        %{assigns: %{invalid_stop_times: stop_times}} = socket
      ) do
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

  def handle_event("add_service_date", %{"value" => index}, socket) do
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

  def handle_event(
        "delete_service_date",
        %{"service_index" => service_index, "date_index" => date_index},
        socket
      ) do
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

  defp handle_progress(:trainsformer_export, %UploadEntry{done?: false}, socket) do
    {:noreply, socket}
  end

  defp handle_progress(
         :trainsformer_export,
         %UploadEntry{client_name: client_name} = entry,
         socket
       ) do
    socket = socket |> clear_flash() |> assign(error: nil)

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
           one_of_north_south_stations: export_data.one_of_north_south_stations,
           missing_routes: export_data.missing_routes,
           invalid_routes: export_data.invalid_routes,
           trips_missing_transfers: export_data.trips_missing_transfers,
           uploaded_file_routes: export_data.routes,
           uploaded_file_services: export_data.services
         )}

      {:error, {:invalid_export_stops, stops}} ->
        {:noreply, assign(socket, invalid_export_stops: stops)}

      {:error, {:invalid_stop_times, stop_times}} ->
        {:noreply, assign(socket, invalid_stop_times: stop_times)}

      {:error, error} ->
        {:noreply, assign(socket, error: error)}
    end
  end

  defp create_export(export_params, socket) do
    imported_services =
      for {key, value} <- export_params["services"],
          into: %{},
          do: {key, value}

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
               "name" => socket.assigns.uploaded_file_name,
               "services" => imported_services
           }) do
      {:noreply,
       socket
       |> push_patch(to: "/disruptions/#{socket.assigns.disruption.id}")
       |> put_flash(:info, "Trainsformer service schedules imported successfully!")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}

      {:error, _} ->
        {:noreply, assign(socket, error: "Failed to upload export to S3")}
    end
  end
end
