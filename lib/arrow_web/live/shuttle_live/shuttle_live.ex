defmodule ArrowWeb.ShuttleViewLive do
  use ArrowWeb, :live_view
  import Phoenix.HTML.Form

  alias Arrow.Shuttles
  alias Arrow.Shuttles.{Route, RouteStop, Shape, Shuttle}
  alias ArrowWeb.ShapeView

  embed_templates "shuttle_live/*"

  @doc """
  Renders a shuttle route form
  """
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :http_action, :string
  attr :gtfs_disruptable_routes, :list, required: true
  attr :shapes, :list, required: true
  attr :map_props, :map, required: false, default: %{}
  attr :errors, :map, required: false, default: %{route_stops: %{}}

  def shuttle_form(assigns) do
    ~H"""
    <.simple_form
      :let={f}
      for={@form}
      as={:shuttle}
      action={@http_action}
      phx-submit={@action}
      id="shuttle-form"
    >
      <div class="form-group">
        <a
          target="_blank"
          rel="noreferrer noopener"
          href="https://www.notion.so/native/mbta-downtown-crossing/Conventions-for-shuttle-bus-information-fc5a788409b24eb088dbfe3a43abf67e?pvs=4&deepLinkOpenNewTab=true#2b8886089b25403991f1ed69144d8fd8"
        >
          View Shuttle Definition Conventions
        </a>
      </div>
      <.error :if={@form.action}>
        Oops, something went wrong! Please check the errors below.
      </.error>
      <div class="row">
        <div class="col">
          <.input field={f[:shuttle_name]} type="text" label="Shuttle Name" />
        </div>
        <div class="col">
          <.input
            field={f[:disrupted_route_id]}
            type="select"
            label="Disrupted Route"
            prompt="Choose a route"
            options={Enum.map(@gtfs_disruptable_routes, &{&1.long_name, &1.id})}
          />
        </div>
        <div class="col">
          <.input
            field={f[:status]}
            type="select"
            label="Status"
            prompt="Choose a value"
            options={Ecto.Enum.values(Arrow.Shuttles.Shuttle, :status)}
          />
        </div>
      </div>
      <%= live_react_component("Components.ShapeStopViewMap", @map_props, id: "shuttle-view-map") %>
      <hr />
      <h2>define route</h2>
      <.inputs_for :let={f_route} field={f[:routes]}>
        <h4>direction <%= input_value(f_route, :direction_id) %></h4>
        <div class="row">
          <div class="hidden">
            <.input field={f_route[:direction_id]} type="text" label="Direction id" />
          </div>
          <div class="col">
            <.input field={f_route[:direction_desc]} type="text" label="Direction desc" />
          </div>
          <div class="col offset-md-1">
            <.live_select
              field={f_route[:shape_id]}
              label="Shape"
              placeholder="Choose a shape"
              options={options_mapper(@shapes)}
              value_mapper={&value_mapper/1}
              allow_clear={true}
            />
          </div>
        </div>
        <div class="row">
          <div class="col">
            <.input field={f_route[:destination]} type="text" label="Destination" />
          </div>
          <div class="col-1 align-self-end italic">
            <div class="form-group">
              via
            </div>
          </div>
          <div class="col">
            <.input field={f_route[:waypoint]} type="text" label="Waypoint" />
          </div>
        </div>
        <div class="row">
          <div class="col">
            <.input field={f_route[:suffix]} type="text" label="Suffix" />
          </div>
        </div>
      </.inputs_for>
      <div class="flex items-center space-x-4">
        <span>If you'd like to upload a shape:</span>
        <.link_button class="btn-primary" href={~p"/shapes_upload"} target="_blank">
          Upload Shape
        </.link_button>
      </div>
      <hr />
      <h2>define stops</h2>
      <.shuttle_form_stops_section f={f} errors={@errors} />
      <:actions>
        <.button>Save Shuttle</.button>
      </:actions>
    </.simple_form>
    """
  end

  attr :f, :any, required: true
  attr :errors, :map, required: true

  defp shuttle_form_stops_section(assigns) do
    ~H"""
    <.inputs_for :let={f_route} field={@f[:routes]} as={:routes_with_stops}>
      <h4>direction <%= input_value(f_route, :direction_id) %></h4>
      <div
        id={"stops-dir-#{input_value(f_route, :direction_id)}"}
        phx-hook="sortable"
        data-direction_id={input_value(f_route, :direction_id)}
      >
        <.inputs_for :let={f_route_stop} field={f_route[:route_stops]}>
          <div
            class="row item align-items-center"
            data-stop_sequence={input_value(f_route_stop, :stop_sequence)}
          >
            <div class="col-lg-1">
              <.icon name="hero-bars-3" class="h-4 w-4 drag-handle cursor-grab" />
            </div>
            <.input field={f_route_stop[:display_stop_id]} label="Stop ID" class="col-lg-6" />
            <.input
              field={f_route_stop[:time_to_next_stop]}
              type="number"
              label="Time to next stop"
              class="col-lg-4"
            />
            <button
              class="btn"
              type="button"
              name={input_name(f_route, :route_stops_drop) <> "[]"}
              value={f_route_stop.index}
              phx-click={JS.dispatch("change")}
            >
              <.icon name="hero-x-mark-solid" class="h-4 w-4" />
            </button>
            <input
              value={f_route_stop.index}
              type="hidden"
              name={input_name(f_route, :route_stops_sort) <> "[]"}
            />
            <input
              value={input_value(f_route_stop, :direction_id)}
              type="hidden"
              name={input_name(f_route_stop, :direction_id)}
            />
            <input
              value={input_value(f_route_stop, :stop_sequence)}
              type="hidden"
              name={input_name(f_route_stop, :stop_sequence)}
            />
          </div>
        </.inputs_for>
      </div>
      <input type="hidden" name={input_name(f_route, :route_stops_drop) <> "[]"} />
      <div class="row form-group">
        <div class="offset-lg-1 col-lg-6">
          <button
            class="btn btn-primary"
            type="button"
            id={"add_stop-#{input_value(f_route, :direction_id)}"}
            value={input_value(f_route, :direction_id)}
            phx-click="add_stop"
          >
            Add Another Stop
          </button>
        </div>
        <div class="col-lg">
          <button
            class="btn btn-primary"
            type="button"
            id={"get_time-#{input_value(f_route, :direction_id)}"}
            value={input_value(f_route, :direction_id)}
            phx-click="get_time_to_next_stop"
          >
            Retrieve Estimates
          </button>
          <aside
            :if={@errors[:route_stops][input_value(f_route, :direction_id)]}
            class="mt-2 text-sm alert alert-danger"
            role="alert"
          >
            <%= @errors[:route_stops][input_value(f_route, :direction_id)] %>
          </aside>
        </div>
      </div>
    </.inputs_for>
    <div class="mt-8 flex items-center space-x-4">
      <span>If you'd like to create a stop:</span>
      <.link_button class="btn-primary" href={~p"/stops/new"} target="_blank">
        Create Stop
      </.link_button>
    </div>
    """
  end

  defp shape_to_shapeview(%Shape{bucket: "disabled"}), do: nil

  defp shape_to_shapeview(%Shape{} = shape) do
    shape
    |> Shuttles.get_shapes_upload()
    |> ShapeView.shapes_map_view()
    |> Map.get(:shapes)
    |> List.first()
  end

  defp shape_to_shapeview(_), do: nil

  defp render_route_stop(%RouteStop{stop_id: stop_id} = route_stop) when not is_nil(stop_id) do
    route_stop =
      if !Ecto.assoc_loaded?(route_stop.stop) or route_stop.stop.id != stop_id,
        do: Arrow.Repo.preload(route_stop, :stop, force: true),
        else: route_stop

    if route_stop.stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: route_stop.stop.stop_id,
        stop_name: route_stop.stop.stop_name,
        stop_desc: route_stop.stop.stop_desc,
        stop_lat: route_stop.stop.stop_lat,
        stop_lon: route_stop.stop.stop_lon
      }
    end
  end

  defp render_route_stop(%RouteStop{gtfs_stop_id: gtfs_stop_id} = route_stop)
       when not is_nil(gtfs_stop_id) do
    route_stop =
      if !Ecto.assoc_loaded?(route_stop.gtfs_stop) or route_stop.gtfs_stop.id != gtfs_stop_id,
        do: Arrow.Repo.preload(route_stop, :gtfs_stop, force: true),
        else: route_stop

    if route_stop.gtfs_stop do
      %{
        stop_sequence: route_stop.stop_sequence,
        stop_id: route_stop.gtfs_stop.id,
        stop_name: route_stop.gtfs_stop.name,
        stop_desc: route_stop.gtfs_stop.desc,
        stop_lat: route_stop.gtfs_stop.lat,
        stop_lon: route_stop.gtfs_stop.lon
      }
    end
  end

  defp render_route_stop(_), do: nil

  defp render_route_stops([_ | _] = route_stops) do
    route_stops |> Enum.map(&render_route_stop/1) |> Enum.filter(& &1)
  end

  defp render_route_stops(_), do: []

  defp direction_to_layer(%Route{} = direction, existing_props) do
    matching_shape =
      existing_props.layers
      |> Enum.map(& &1.shape)
      |> Enum.find(&(&1 && direction.shape_id && &1.name == direction.shape.name))

    shape = if matching_shape, do: matching_shape, else: shape_to_shapeview(direction.shape)

    stops = render_route_stops(direction.route_stops)

    %{
      name: direction.direction_desc,
      direction_id: direction.direction_id,
      shape: shape,
      stops: stops
    }
  end

  defp routes_to_layers(routes, existing_props) do
    routes
    |> Enum.sort_by(& &1.direction_id)
    |> Enum.map(&direction_to_layer(&1, existing_props))
  end

  defp routes_to_layers(routes) do
    routes_to_layers(routes, %{layers: []})
  end

  defp options_mapper(shapes) do
    Enum.map(shapes, &option_mapper/1)
  end

  def option_mapper(%{name: name, id: id}) do
    {name, value_mapper(id)}
  end

  def value_mapper(id) when is_integer(id) do
    Integer.to_string(id)
  end

  def value_mapper(id) do
    id
  end

  def mount(%{"id" => id} = _params, _session, socket) do
    shuttle = Shuttles.get_shuttle!(id)
    changeset = Shuttles.change_shuttle(shuttle)
    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()
    form = to_form(changeset)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "edit")
      |> assign(:http_action, ~p"/shuttles/#{id}")
      |> assign(:shuttle, shuttle)
      |> assign(:title, "edit shuttle")
      |> assign(:gtfs_disruptable_routes, gtfs_disruptable_routes)
      |> assign(:shapes, shapes)
      |> assign(:map_props, %{layers: routes_to_layers(shuttle.routes)})
      |> assign(:errors, %{route_stops: %{}})

    {:ok, socket}
  end

  def mount(%{} = _params, _session, socket) do
    shuttle = %Shuttle{
      status: :draft,
      routes: [%Shuttles.Route{direction_id: :"0"}, %Shuttles.Route{direction_id: :"1"}]
    }

    gtfs_disruptable_routes = Shuttles.list_disruptable_routes()
    shapes = Shuttles.list_shapes()
    form = shuttle |> Shuttles.change_shuttle() |> to_form()

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "create")
      |> assign(:http_action, ~p"/shuttles")
      |> assign(:title, "create new replacement service shuttle")
      |> assign(:shuttle, shuttle)
      |> assign(:gtfs_disruptable_routes, gtfs_disruptable_routes)
      |> assign(:shapes, shapes)
      |> assign(:map_props, %{layers: routes_to_layers(shuttle.routes)})
      |> assign(:errors, %{route_stops: %{}})

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    validate(params, socket)
  end

  def handle_event("edit", params, socket) do
    shuttle_params = params |> combine_params()

    shuttle = Shuttles.get_shuttle!(socket.assigns.shuttle.id)

    case Shuttles.update_shuttle(shuttle, shuttle_params) do
      {:ok, shuttle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shuttle updated successfully")
         |> redirect(to: ~p"/shuttles/#{shuttle}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("create", params, socket) do
    shuttle_params = params |> combine_params()

    case Shuttles.create_shuttle(shuttle_params) do
      {:ok, shuttle} ->
        {:noreply,
         socket
         |> put_flash(:info, "Shuttle created successfully")
         |> redirect(to: ~p"/shuttles/#{shuttle}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("live_select_change", %{"text" => text, "id" => live_select_id}, socket) do
    shapes =
      Shuttles.list_shapes()
      |> Enum.filter(&(String.downcase(&1.name) |> String.contains?(String.downcase(text))))
      |> Enum.map(&option_mapper/1)

    send_update(LiveSelect.Component, id: live_select_id, options: shapes)

    {:noreply, socket}
  end

  def handle_event("add_stop", %{"value" => direction_id}, socket) do
    direction_id = String.to_existing_atom(direction_id)

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing_routes = Ecto.Changeset.get_assoc(changeset, :routes)

        new_routes =
          Enum.map(existing_routes, fn route_changeset ->
            update_route_changeset_with_new_stop(route_changeset, direction_id)
          end)

        changeset = Ecto.Changeset.put_assoc(changeset, :routes, new_routes)

        to_form(changeset)
      end)

    {:noreply, socket}
  end

  def handle_event(
        "reorder_stops",
        %{
          "direction_id" => direction_id,
          "old" => old,
          "new" => new
        },
        socket
      ) do
    direction_id = String.to_existing_atom(direction_id)

    changeset = socket.assigns.form.source
    existing_routes = Ecto.Changeset.get_assoc(changeset, :routes)

    new_routes =
      Enum.map(existing_routes, fn route_changeset ->
        update_route_changeset_with_reordered_stops(route_changeset, direction_id, old, new)
      end)

    changeset = Ecto.Changeset.put_assoc(changeset, :routes, new_routes)

    socket = socket |> assign(:form, to_form(changeset)) |> update_map(changeset)

    {:noreply, socket}
  end

  def handle_event("get_time_to_next_stop", %{"value" => direction_id}, socket) do
    direction_id = String.to_existing_atom(direction_id)

    changeset = socket.assigns.form.source

    {routes, other_routes} =
      changeset
      |> Ecto.Changeset.get_assoc(:routes)
      |> Enum.split_with(&(Ecto.Changeset.get_field(&1, :direction_id) == direction_id))

    new_route =
      routes
      |> Enum.find(&(Ecto.Changeset.get_field(&1, :direction_id) == direction_id))
      |> update_route_changeset_with_stop_time_estimates()

    case new_route do
      {:ok, new_route_changeset} ->
        changeset =
          Ecto.Changeset.put_assoc(
            changeset,
            :routes,
            Enum.sort_by(
              [new_route_changeset | other_routes],
              &Ecto.Changeset.get_field(&1, :direction_id)
            )
          )

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))}

      {:error, error} ->
        socket =
          update(socket, :errors, fn errors ->
            put_in(errors, [:route_stops, Access.key(direction_id, [])], error)
          end)

        {:noreply, socket}
    end
  end

  defp combine_params(%{
         "shuttle" => shuttle_params,
         "routes_with_stops" => routes_with_stops_params
       }) do
    %{
      shuttle_params
      | "routes" =>
          shuttle_params
          |> Map.get("routes")
          |> Map.new(fn {route_index, route} ->
            route_stop_fields =
              Map.take(routes_with_stops_params[route_index], [
                "route_stops",
                "route_stops_drop",
                "route_stops_sort"
              ])

            {route_index, Map.merge(route, route_stop_fields)}
          end)
    }
  end

  @spec get_stop_travel_times(list({:ok, any()})) ::
          {:ok, list(number())} | {:error, any()}
  defp get_stop_travel_times(stop_coordinates) do
    stop_coordinates
    |> Enum.map(fn {:ok, c} -> c end)
    |> Shuttles.get_travel_times()
  end

  defp update_route_changeset_with_stop_time_estimates(route_changeset) do
    existing_stops_changeset = Ecto.Changeset.get_assoc(route_changeset, :route_stops)
    existing_stops_data = Ecto.Changeset.get_field(route_changeset, :route_stops)
    stop_coordinates = Enum.map(existing_stops_data, &Shuttles.get_stop_coordinates/1)

    with true <- Enum.all?(stop_coordinates, &match?({:ok, _}, &1)),
         {:ok, stop_durations} <- get_stop_travel_times(stop_coordinates) do
      updated_stops =
        existing_stops_changeset
        |> Enum.zip(stop_durations ++ [nil])
        |> Enum.map(fn {stop_changeset, duration} ->
          Ecto.Changeset.put_change(stop_changeset, :time_to_next_stop, duration)
        end)

      {:ok,
       Ecto.Changeset.put_assoc(
         route_changeset,
         :route_stops,
         updated_stops
       )}
    else
      {:error, error} ->
        {:error, error}

      false ->
        coordinate_errors =
          stop_coordinates
          |> Enum.filter(&match?({:error, _}, &1))
          |> Enum.map_join(", ", fn {:error, msg} -> "#{msg}" end)

        {:error, coordinate_errors}
    end
  end

  defp update_route_changeset_with_new_stop(route_changeset, direction_id) do
    if Ecto.Changeset.get_field(route_changeset, :direction_id) == direction_id do
      existing_stops = Ecto.Changeset.get_field(route_changeset, :route_stops)

      max_stop_sequence =
        existing_stops |> Enum.map(& &1.stop_sequence) |> Enum.max(fn -> 0 end)

      new_route_stop = %Arrow.Shuttles.RouteStop{
        direction_id: direction_id,
        stop_sequence: max_stop_sequence + 1
      }

      Ecto.Changeset.put_assoc(
        route_changeset,
        :route_stops,
        existing_stops ++ [new_route_stop]
      )
    else
      route_changeset
    end
  end

  defp update_route_changeset_with_reordered_stops(route_changeset, direction_id, old, new) do
    if Ecto.Changeset.get_field(route_changeset, :direction_id) == direction_id do
      existing_stops = Ecto.Changeset.get_field(route_changeset, :route_stops)

      moved_route_stop = Enum.at(existing_stops, old)

      {new_route_stop_changes, _stop_sequence} =
        existing_stops
        |> List.delete_at(old)
        |> List.insert_at(new, moved_route_stop)
        |> Enum.reduce({[], 0}, fn route_stop, {route_stop_changes, stop_sequence} ->
          {route_stop_changes ++
             [Arrow.Shuttles.RouteStop.changeset(route_stop, %{stop_sequence: stop_sequence})],
           stop_sequence + 1}
        end)

      Ecto.Changeset.put_assoc(
        route_changeset,
        :route_stops,
        new_route_stop_changes
      )
    else
      route_changeset
    end
  end

  defp update_map(socket, changeset) do
    layers =
      changeset
      |> Ecto.Changeset.get_assoc(:routes, :struct)
      |> Enum.map(&Arrow.Repo.preload(&1, :shape, force: true))
      |> routes_to_layers(socket.assigns.map_props)

    assign(socket, :map_props, %{layers: layers})
  end

  defp validate(params, socket) do
    shuttle_params = params |> combine_params()

    change = Shuttles.change_shuttle(socket.assigns.shuttle, shuttle_params)
    form = to_form(change, action: :validate)

    {:noreply, socket |> assign(form: form) |> update_map(change)}
  end
end
