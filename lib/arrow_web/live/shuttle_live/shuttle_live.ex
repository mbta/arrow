defmodule ArrowWeb.ShuttleViewLive do
  use ArrowWeb, :live_view
  import Phoenix.HTML.Form
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle
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
  attr :uploads, :any

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
      <div class="row mb-3">
        <div class="col">
          <.link_button
            class="btn-primary"
            phx-click={JS.dispatch("click", to: "##{@uploads.definition.ref}")}
            target="_blank"
          >
            <.live_file_input upload={@uploads.definition} class="hidden" />
            Upload Shuttle Definition XLSX
          </.link_button>
        </div>
      </div>
      <%= live_react_component("Components.ShapeViewMap", @map_props, id: "shuttle-view-map") %>
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
      <.shuttle_form_stops_section f={f} />
      <:actions>
        <.button>Save Shuttle</.button>
      </:actions>
    </.simple_form>
    """
  end

  attr :f, :any, required: true

  defp shuttle_form_stops_section(assigns) do
    ~H"""
    <.inputs_for :let={f_route} field={@f[:routes]} as={:routes_with_stops}>
      <h4>direction <%= input_value(f_route, :direction_id) %></h4>
      <div
        class="container"
        id={"stops-dir-#{input_value(f_route, :direction_id)}"}
        phx-hook="sortable"
        data-direction_id={input_value(f_route, :direction_id)}
      >
        <.inputs_for :let={f_route_stop} field={f_route[:route_stops]}>
          <div class="row item" data-stop_sequence={input_value(f_route_stop, :stop_sequence)}>
            <.icon name="hero-bars-3" class="h-4 w-4 drag-handle col-lg-1 cursor-grab" />
            <.input field={f_route_stop[:display_stop_id]} label="Stop ID" class="col-lg-6" />
            <.input
              field={f_route_stop[:time_to_next_stop]}
              type="number"
              label="Time to next stop"
              class="col-lg-4"
            />
            <button
              type="button"
              name={input_name(f_route, :route_stops_drop) <> "[]"}
              value={f_route_stop.index}
              phx-click={JS.dispatch("change")}
              class="col-lg-1"
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
      <button type="button" value={input_value(f_route, :direction_id)} phx-click="add_stop">
        Add Another Stop
      </button>
    </.inputs_for>
    <div class="mt-8 flex items-center space-x-4">
      <span>If you'd like to create a stop:</span>
      <.link_button class="btn-primary" href={~p"/stops/new"} target="_blank">
        Create Stop
      </.link_button>
    </div>
    """
  end

  defp shapes_to_shapeviews(shapes) do
    shapes
    |> Enum.map(&Shuttles.get_shapes_upload/1)
    |> Enum.reject(&(&1 == {:ok, :disabled}))
    |> Enum.map(&ShapeView.shapes_map_view/1)
    |> Enum.map(&List.first(&1.shapes))
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

    shuttle_shapes =
      shuttle
      |> Map.get(:routes)
      |> Enum.map(&Map.get(&1, :shape))
      |> Enum.reject(&is_nil/1)

    shapes_map_view = shapes_to_shapeviews(shuttle_shapes)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:form_action, "edit")
      |> assign(:http_action, ~p"/shuttles/#{id}")
      |> assign(:shuttle, shuttle)
      |> assign(:title, "edit shuttle")
      |> assign(:gtfs_disruptable_routes, gtfs_disruptable_routes)
      |> assign(:shapes, shapes)
      |> assign(:map_props, %{shapes: shapes_map_view})
      |> allow_upload(:definition,
        accept: ~w(.xlsx),
        progress: &handle_progress/3,
        auto_upload: true
      )

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
      |> assign(:map_props, %{shapes: []})
      |> allow_upload(:definition,
        accept: ~w(.xlsx),
        progress: &handle_progress/3,
        auto_upload: true
      )

    {:ok, socket}
  end

  # A new shape is selected
  def handle_event(
        "validate",
        %{"_target" => ["shuttle", "routes", _direction_id, "shape_id"]} = params,
        socket
      ) do
    shapes =
      [
        params["shuttle"]["routes"]["0"]["shape_id"],
        params["shuttle"]["routes"]["1"]["shape_id"]
      ]
      |> Enum.reject(&(&1 == ""))
      |> Shuttles.get_shapes()
      |> shapes_to_shapeviews()

    validate(params, assign(socket, :map_props, %{socket.assigns.map_props | shapes: shapes}))
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

    socket =
      update(socket, :form, fn %{source: changeset} ->
        existing_routes = Ecto.Changeset.get_assoc(changeset, :routes)

        new_routes =
          Enum.map(existing_routes, fn route_changeset ->
            update_route_changeset_with_reordered_stops(route_changeset, direction_id, old, new)
          end)

        changeset = Ecto.Changeset.put_assoc(changeset, :routes, new_routes)

        to_form(changeset)
      end)

    {:noreply, socket}
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

  defp update_route_changeset_with_uploaded_stops(route_changeset, stop_ids, direction_id) do
    if Ecto.Changeset.get_field(route_changeset, :direction_id) == direction_id do
      new_route_stops =
        stop_ids
        |> Enum.with_index()
        |> Enum.map(fn {stop_id, i} ->
          Arrow.Shuttles.RouteStop.changeset(
            %Arrow.Shuttles.RouteStop{},
            %{
              direction_id: direction_id,
              stop_sequence: i,
              display_stop_id: Integer.to_string(stop_id)
            }
          )
        end)

      Ecto.Changeset.put_assoc(
        route_changeset,
        :route_stops,
        new_route_stops
      )
    else
      route_changeset
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

  defp validate(params, socket) do
    shuttle_params = params |> combine_params()

    form =
      socket.assigns.shuttle
      |> Shuttles.change_shuttle(shuttle_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  defp handle_progress(:definition, entry, socket) do
    socket = clear_flash(socket)

    if entry.done? do
      case extract_stop_ids_from_upload(socket, entry) do
        {:error, errors} ->
          {:noreply, put_flash(socket, :errors, {"Failed to upload definition:", errors})}

        stop_ids ->
          socket = populate_stop_ids(socket, stop_ids)

          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  defp populate_stop_ids(socket, stop_ids) do
    update(socket, :form, fn %{source: changeset} ->
      existing_routes = Ecto.Changeset.get_assoc(changeset, :routes)

      new_routes =
        Enum.map(existing_routes, fn route_changeset ->
          direction_id = Ecto.Changeset.get_field(route_changeset, :direction_id)

          update_route_changeset_with_uploaded_stops(
            route_changeset,
            Enum.at(stop_ids, direction_id |> Atom.to_string() |> String.to_integer()),
            direction_id
          )
        end)

      changeset = Ecto.Changeset.put_assoc(changeset, :routes, new_routes)

      to_form(changeset)
    end)
  end

  defp extract_stop_ids_from_upload(socket, entry) do
    consume_uploaded_entry(socket, entry, fn %{path: path} ->
      with pids when is_list(pids) <- Xlsxir.multi_extract(path),
           {:ok,
            %{
              "Direction 0 STOPS" => direction_0_tab_pid,
              "Direction 1 STOPS" => direction_1_tab_pid
            } = tab_pid_map} <- get_xlsx_tab_pids(pids),
           {:ok, direction_0_stop_ids} <- parse_direction_tab(direction_0_tab_pid),
           {:ok, direction_1_stop_ids} <- parse_direction_tab(direction_1_tab_pid),
           :ok <- Enum.each(tab_pid_map, &Xlsxir.close/1) do
        {:ok, [direction_0_stop_ids, direction_1_stop_ids]}
      else
        {:error, error} -> {:ok, {:error, [error]}}
        {:errors, errors} -> {:ok, {:error, errors}}
      end
    end)
  end

  defp get_xlsx_tab_pids(tab_pids) do
    tab_map =
      tab_pids
      |> Enum.map(fn {:ok, pid} -> {Xlsxir.get_info(pid, :name), pid} end)
      |> Map.new()

    case {tab_map["Direction 0 STOPS"], tab_map["Direction 1 STOPS"]} do
      {nil, nil} -> {:error, "Missing tabs for both directions"}
      {nil, _} -> {:error, "Missing Direction 0 STOPS tab"}
      {_, nil} -> {:error, "Missing Direction 1 STOPS tab"}
      _ -> {:ok, tab_map}
    end
  end

  defp parse_direction_tab(table_id) do
    tab_data =
      table_id
      |> Xlsxir.get_list()
      # Cells that have been touched but are empty can return nil
      |> Enum.reject(fn list -> Enum.all?(list, &is_nil/1) end)

    case validate_sheet(tab_data) do
      :ok ->
        stop_ids =
          tab_data
          # Drop header row
          |> Enum.drop(1)
          |> Enum.map(fn [_, stop_id | _] -> stop_id end)

        {:ok, stop_ids}

      errors ->
        errors
    end
  end

  defp validate_sheet([headers | _] = data) do
    errors =
      data
      |> Enum.with_index()
      |> Enum.reduce([], fn {row, i}, acc ->
        stop_id = Enum.at(row, 1)
        row_number = i + 1

        acc
        |> append_if(
          length(row) < 2,
          "Invalid/missing columns on row #{row_number}"
        )
        |> append_if(
          stop_id != "Stop ID" and (is_nil(stop_id) or not is_integer(stop_id)),
          "Missing/invalid stop ID on row #{row_number}"
        )
      end)
      |> append_if(
        headers != ["Stop Name", "Stop ID", "Notes"],
        "Invalid/missing headers"
      )

    if Enum.empty?(errors), do: :ok, else: {:errors, errors}
  end

  defp append_if(list, condition, item) do
    if condition, do: list ++ [item], else: list
  end
end
