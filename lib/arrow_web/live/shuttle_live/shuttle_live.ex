defmodule ArrowWeb.ShuttleViewLive do
  use ArrowWeb, :live_view
  import Phoenix.HTML.Form
  alias Arrow.Shuttles
  alias Arrow.Shuttles.Shuttle

  embed_templates "shuttle_live/*"

  @doc """
  Renders a shuttle route form
  """
  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :http_action, :string
  attr :gtfs_disruptable_routes, :list, required: true
  attr :shapes, :list, required: true

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
            <.input
              field={f_route[:shape_id]}
              type="select"
              label="Shape"
              prompt="Choose a shape"
              options={Enum.map(@shapes, &{&1.name, &1.id})}
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
      <h2>define stops</h2>
      <.inputs_for :let={f_route} field={f[:routes]} as={:routes_with_stops}>
        <h4>direction <%= input_value(f_route, :direction_id) %></h4>
        <.inputs_for :let={f_route_stop} field={f_route[:route_stops]}>
          <.input field={f_route_stop[:display_stop_id]} label="Stop ID" />
          <.input field={f_route_stop[:time_to_next_stop]} type="number" label="Time to next stop" />
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
        </.inputs_for>
      </.inputs_for>
      <:actions>
        <.button>Save Shuttle</.button>
      </:actions>
    </.simple_form>
    """
  end

  def mount(%{"id" => id} = _params, session, socket) do
    logout_url = session["logout_url"]
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
      |> assign(:logout_url, logout_url)

    {:ok, socket}
  end

  def mount(%{} = _params, session, socket) do
    logout_url = session["logout_url"]

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
      |> assign(:logout_url, logout_url)

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    shuttle_params = params |> combine_params()

    form =
      socket.assigns.shuttle
      |> Shuttles.change_shuttle(shuttle_params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
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
            {route_index,
             Map.put(
               route,
               "route_stops",
               routes_with_stops_params[route_index]["route_stops"] || []
             )}
          end)
    }
  end
end
