defmodule ArrowWeb.StopViewLive do
  use ArrowWeb, :live_view

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles.Stop
  alias Arrow.Stops
  embed_templates "stop_live/*"

  @doc """
  Renders a stop form.
  """
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :trigger_submit, :boolean, required: true
  attr :http_action, :string

  def stop_form(assigns) do
    ~H"""
    <p>
      <small class="font-italic">
        * required field
      </small>
      <br />
      <a
        target="_blank"
        class="text-sm"
        href="https://www.notion.so/mbta-downtown-crossing/Conventions-for-shuttle-bus-information-fc5a788409b24eb088dbfe3a43abf67e?pvs=4#7f7211396f6c46e59c26e63373cdb4ac"
      >
        View Shuttle Stop Conventions
      </a>
    </p>
    <.simple_form
      :let={f}
      for={@form}
      as={:stop}
      action={@http_action}
      phx-change="validate"
      phx-submit={@action}
      phx-trigger-action={@trigger_submit}
      id="stop-form"
    >
      <.error :if={@form.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <div class="form-row">
        <.input class="col-md-6" field={f[:stop_id]} type="text" label="Stop ID*" />
      </div>
      <.input field={f[:stop_name]} type="text" label="Stop Name*" />
      <.input field={f[:stop_desc]} type="text" label="Stop Description*" />
      <.input class="w-auto" field={f[:platform_code]} type="text" label="Platform Code" />
      <.input field={f[:platform_name]} type="text" label="Platform Name" />
      <.input field={f[:parent_station]} type="text" label="Parent Station" />
      <div class="form-row">
        <.input class="col-md-6" field={f[:level_id]} type="text" label="Level ID" />
      </div>
      <div class="form-row">
        <.input class="col-md-6" field={f[:zone_id]} type="text" label="Zone ID" />
      </div>

      <div class="form-row">
        <.input class="col-md-6" field={f[:stop_lat]} type="number" label="Latitude*" step="any" />
        <.input class="col-md-6" field={f[:stop_lon]} type="number" label="Longitude*" step="any" />
      </div>
      <.input field={f[:municipality]} type="text" label="Municipality*" />
      <.input field={f[:stop_address]} type="text" label="Stop Address" />
      <.input field={f[:on_street]} type="text" label="Street" />
      <.input field={f[:at_street]} type="text" label="Cross street" />
      <:actions>
        <div class="w-25 mr-2">
          <.button type="submit" class="btn-primary w-100">Save Shuttle Stop</.button>
        </div>
        <div class="w-25 mr-2">
          <.link_button
            href={~p"/stops"}
            class="btn-outline-primary w-100"
            data-confirm="Are you sure you want to cancel? All changes will be lost!"
          >
            Cancel
          </.link_button>
        </div>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"stop_id" => stop_id} = _params, _session, socket) do
    stop = Stops.get_stop_by_stop_id!(stop_id)
    form = to_form(Stops.change_stop(stop))

    # get stops from arrow DB and gtfs, excluding current stop
    existing_stops =
      Stops.get_stops_within_mile(stop.stop_id, {stop.stop_lat, stop.stop_lon})

    existing_gtfs_stops =
      GtfsStop.get_stops_within_mile(stop.stop_id, {stop.stop_lat, stop.stop_lon})

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "edit")
      |> assign(:http_action, ~p"/stops/#{stop.id}")
      |> assign(:stop, stop)
      |> assign(:title, "edit shuttle stop")
      |> assign(:stop_map_props, stop)
      |> assign(:existing_stops, existing_stops)
      |> assign(:existing_gtfs_stops, existing_gtfs_stops)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    form = to_form(Stops.change_stop(%Stop{}))

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/stops")
      |> assign(:stop, %Stop{})
      |> assign(:title, "create shuttle stop")
      |> assign(:stop_map_props, %{})
      |> assign(:existing_stops, [])
      |> assign(:existing_gtfs_stops, [])
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate", %{"stop" => stop_params}, socket) do
    form = Stops.change_stop(socket.assigns.stop, stop_params) |> to_form(action: :validate)

    {existing_stops, existing_gtfs_stops} =
      with %{"stop_lat" => lat, "stop_lon" => lon, "stop_id" => stop_id} <- stop_params,
           {float_lat, _} <- Float.parse(lat),
           {float_lon, _} <- Float.parse(lon) do
        {Stops.get_stops_within_mile(stop_id, {float_lat, float_lon}),
         GtfsStop.get_stops_within_mile(stop_id, {float_lat, float_lon})}
      else
        _ -> {nil, nil}
      end

    {:noreply,
     socket
     |> assign(
       stop_map_props: stop_params,
       form: form,
       existing_stops: existing_stops,
       existing_gtfs_stops: existing_gtfs_stops
     )}
  end

  def handle_event("edit", %{"stop" => stop_params}, socket) do
    stop = Stops.get_stop!(socket.assigns.stop.id)

    case Arrow.Stops.update_stop(stop, stop_params) do
      {:ok, _stop} ->
        {:noreply,
         socket
         |> put_flash(:info, "Stop edited successfully")
         |> redirect(to: ~p"/stops")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("create", %{"stop" => stop_params}, socket) do
    case Arrow.Stops.create_stop(stop_params) do
      {:ok, _stop} ->
        {:noreply,
         socket
         |> put_flash(:info, "Stop created successfully")
         |> redirect(to: ~p"/stops")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
