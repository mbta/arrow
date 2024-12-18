defmodule ArrowWeb.StopViewLive do
  use ArrowWeb, :live_view

  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Repo
  alias Arrow.Shuttles.Stop
  alias Arrow.Stops
  import Ecto.Query
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

  def mount(%{"id" => id} = _params, _session, socket) do
    stop = Stops.get_stop!(id)
    form = to_form(Stops.change_stop(stop))

    # get stops from arrow DB and gtfs, excluding current stop
    existing_stops =
      from(s in Stop,
        where: s.stop_id != ^stop.stop_id
      )
      |> Repo.all()

    existing_gtfs_stops =
      from(g in GtfsStop,
        where: g.id != ^stop.stop_id
      )
      |> Repo.all()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "edit")
      |> assign(:http_action, ~p"/stops/#{id}")
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

    # eventually we should only load a limited number of stops to avoid performance issues
    # but this should be fine while the cardinality of stops is low
    existing_stops = Stops.list_stops()
    existing_gtfs_stops = Repo.all(GtfsStop)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/stops")
      |> assign(:stop, %Stop{})
      |> assign(:title, "create shuttle stop")
      |> assign(:stop_map_props, %{})
      |> assign(:existing_stops, existing_stops)
      |> assign(:existing_gtfs_stops, existing_gtfs_stops)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def degrees_to_radians(degrees) do
    degrees * :math.pi() / 180
  end

  def haversine_distance({lat, lon}, {other_lat, other_lon}) do
    earth_radius_miles = 3963.1

    delta_lat_rads = degrees_to_radians(other_lat - lat)
    delta_lon_rads = degrees_to_radians(other_lon - lon)

    arc =
      :math.cos(degrees_to_radians(lat)) *
        :math.cos(degrees_to_radians(other_lat)) *
        :math.sin(delta_lon_rads / 2) *
        :math.sin(delta_lon_rads / 2) +
        :math.sin(delta_lat_rads / 2) *
          :math.sin(delta_lat_rads / 2)

    line = 2 * :math.atan2(:math.sqrt(arc), :math.sqrt(1 - arc))

    earth_radius_miles * line
  end

  def handle_event("validate", %{"stop" => stop_params}, socket) do
    form = Stops.change_stop(socket.assigns.stop, stop_params) |> to_form(action: :validate)

    %{"stop_lat" => lat, "stop_lon" => lon} = stop_params

    stop_id = Map.get(stop_params, "id")

    {lat, lon} =
      try do
        {String.to_float(lat), String.to_float(lon)}
      rescue
        _ -> {nil, nil}
      end

    existing_stops =
      if is_float(lat) and is_float(lon) and !is_nil(stop_id) do
        from(s in Stop,
          where: s.stop_id != ^stop_id
        )
        |> Repo.all()
        |> Enum.filter(&haversine_distance({&1.stop_lat, &1.stop_lon}, {lat, lon})) <= 1
      else
        nil
      end

    existing_gtfs_stops =
      if is_float(lat) and is_float(lon) and !is_nil(stop_id) do
        from(s in GtfsStop,
          where: s.stop_id != ^stop_id
        )
        |> Repo.all()
        |> Enum.filter(&haversine_distance({&1.lat, &1.lon}, {lat, lon})) <= 1
      else
        nil
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
