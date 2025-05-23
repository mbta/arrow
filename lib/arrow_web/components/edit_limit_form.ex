defmodule ArrowWeb.EditLimitForm do
  @moduledoc false
  use ArrowWeb, :live_component

  alias Arrow.Disruptions.Limit
  alias Arrow.Limits
  alias Arrow.Limits.LimitDayOfWeek

  import Phoenix.HTML.Form
  import Ecto.Query, only: [from: 2]

  attr :limit, Limit, required: true
  attr :icon_paths, :map, required: true

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
        :if={!is_nil(@limit_form)}
        for={@limit_form}
        id="limit-form"
        phx-submit="save"
        phx-change="validate"
        phx-target={@myself}
      >
        <input
          value={input_value(@limit_form, :disruption_id)}
          type="hidden"
          name={input_name(@limit_form, :disruption_id)}
        />
        <div class="container-fluid border-2 border-dashed border-primary p-3">
          <h4 class="text-primary">
            {if @limit.id, do: "edit disruption limit", else: "add new disruption limit"}
          </h4>
          <div class="row mb-3">
            <div class="col-lg-3">
              <.input
                class="h-100"
                id="select-route-id"
                field={@limit_form[:route_id]}
                type="select"
                label="route"
                prompt="Choose a route"
                options={get_route_options()}
              />
            </div>
            <div class="col-lg-3">
              <.input
                class="h-100"
                field={@limit_form[:start_stop_id]}
                type="select"
                label="start stop"
                prompt="Choose a stop"
                disabled={input_value(@limit_form, :route_id) in [nil, ""]}
                options={get_stops_for_route(input_value(@limit_form, :route_id))}
              />
            </div>
            <div class="align-self-end">
              to
            </div>
            <div class="col-lg-3">
              <.input
                class="h-100"
                field={@limit_form[:end_stop_id]}
                type="select"
                label="end stop"
                prompt="Choose a stop"
                disabled={input_value(@limit_form, :route_id) in [nil, ""]}
                options={get_stops_for_route(input_value(@limit_form, :route_id))}
              />
            </div>
          </div>
          <div class="row mb-3">
            <.input class="col-lg-3" field={@limit_form[:start_date]} type="date" label="start date" />
            <.input class="col-lg-3" field={@limit_form[:end_date]} type="date" label="end date" />
            <div class="col text-sm text-danger align-self-center">
              {get_limit_date_range_warning(input_value(@limit_form, :end_date))}
            </div>
          </div>
          <div class={[
            "container-fluid justify-content-around mb-3",
            limit_day_of_weeks_used?(@limit_form) && @limit_form[:limit_day_of_weeks].errors != [] &&
              "is-invalid"
          ]}>
            <.inputs_for :let={f_day_of_week} field={@limit_form[:limit_day_of_weeks]}>
              <div class="row">
                <input
                  value={input_value(f_day_of_week, :day_name)}
                  type="hidden"
                  name={input_name(f_day_of_week, :day_name)}
                />
                <div class="col col-lg-1">
                  <.input type="checkbox" field={f_day_of_week[:active?]} />
                </div>
                <div class="col col-lg-2">
                  <div class="border-2 border-solid border-primary text-center py-2 rounded-lg">
                    {format_day_name(input_value(f_day_of_week, :day_name))}
                  </div>
                </div>
                <div class="col col-lg-3">
                  <.input
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    field={f_day_of_week[:start_time]}
                    disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                    phx-hook="LimitTime"
                  />
                </div>
                <div class="col col-lg-3">
                  <.input
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    field={f_day_of_week[:end_time]}
                    disabled={normalize_value("checkbox", input_value(f_day_of_week, :all_day?))}
                    phx-hook="LimitTime"
                  />
                </div>
                <div class="col">
                  <div
                    :if={normalize_value("checkbox", input_value(f_day_of_week, :active?))}
                    class="flex"
                  >
                    <.input
                      class="mr-2"
                      field={f_day_of_week[:all_day?]}
                      type="checkbox"
                      label="all day"
                    />
                  </div>
                </div>
              </div>
              <div :for={err <- f_day_of_week[:day_name].errors} class="row">
                <div class="col text-sm text-danger mb-3">
                  <.icon name="hero-exclamation-circle-mini" class="h-4 w-4" />
                  {translate_error(err)}
                </div>
              </div>
            </.inputs_for>
          </div>
          <.error :for={err <- @limit_form[:limit_day_of_weeks].errors}>
            {translate_error(err)}
          </.error>
          <div class="row">
            <div class="col-lg-3">
              <.button type="submit" class="btn-primary btn-sm w-100" phx-target={@myself}>
                Save limit
              </.button>
            </div>
            <div class="col-lg-3">
              <.link
                id="cancel_add_limit_button"
                class="btn btn-outline-primary btn-sm w-100"
                data-confirm="Are you sure you want to cancel? All changes to this limit will be lost!"
                patch={~p"/disruptions/#{@limit.disruption_id}"}
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
  def update(assigns, socket) do
    day_of_weeks =
      Enum.map(assigns.limit.limit_day_of_weeks, &LimitDayOfWeek.set_all_day_default/1)

    limit = %{assigns.limit | limit_day_of_weeks: day_of_weeks}
    form = limit |> Limits.change_limit() |> to_form()
    {:ok, assign(socket, limit_form: form, limit: limit)}
  end

  @impl true
  def handle_event("validate", %{"limit" => limit_params}, socket) do
    form =
      socket.assigns.limit
      |> Limits.change_limit(%{
        limit_params
        | "disruption_id" => socket.assigns.limit.disruption_id
      })
      |> to_form(action: :validate)

    {:noreply, assign(socket, limit_form: form)}
  end

  def handle_event("save", %{"limit" => limit_params}, socket) do
    if socket.assigns.limit.id do
      update_limit(socket, limit_params)
    else
      create_limit(socket, limit_params)
    end
  end

  def create_limit(socket, params) do
    case Limits.create_limit(%{params | "disruption_id" => socket.assigns.limit.disruption_id}) do
      {:ok, limit} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/disruptions/#{limit.disruption_id}")
         |> put_flash(:info, "Limit created successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, limit_form: to_form(changeset))}
    end
  end

  def update_limit(socket, params) do
    case Limits.update_limit(socket.assigns.limit, params) do
      {:ok, limit} ->
        {:noreply,
         socket
         |> push_patch(to: ~p"/disruptions/#{limit.disruption_id}")
         |> put_flash(:info, "Limit updated successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, limit_form: to_form(changeset))}
    end
  end

  defp get_route_options do
    from(r in Arrow.Gtfs.Route, where: r.type in [:light_rail, :heavy_rail])
    |> Arrow.Repo.all()
    |> Enum.map(&{&1.long_name, &1.id})
  end

  defp get_stops_for_route(nil), do: []

  defp get_stops_for_route(route_id) do
    Arrow.Repo.all(
      from t in Arrow.Gtfs.Trip,
        where: t.route_id == ^route_id and t.direction_id == 0 and t.service_id == "canonical",
        join: st in Arrow.Gtfs.StopTime,
        on: t.id == st.trip_id,
        join: s in Arrow.Gtfs.Stop,
        on: s.id == st.stop_id,
        where: s.location_type == :stop_platform,
        select: s,
        order_by: st.stop_sequence
    )
    |> Enum.uniq_by(& &1.parent_station_id)
    |> Enum.map(&{&1.name, &1.parent_station_id})
  end

  defp limit_day_of_weeks_used?(form) do
    # Typically you could use `used_input?(form[:limit_day_of_weeks])` but that
    # doesn't work for these subforms because the hidden inputs mark the
    # subform as used. So instead we check the user controlled values of each of
    # these subforms.
    form[:limit_day_of_weeks].value
    |> Enum.any?(fn dow ->
      dow_form =
        case dow do
          %Ecto.Changeset{} = dow_changeset ->
            to_form(dow_changeset)

          %LimitDayOfWeek{} = dow ->
            dow
            |> LimitDayOfWeek.changeset()
            |> to_form()

          {_, params} ->
            %LimitDayOfWeek{}
            |> LimitDayOfWeek.changeset(params)
            |> to_form()
        end

      Enum.any?(
        [:active?, :start_time, :end_time, :all_day?],
        &Phoenix.Component.used_input?(dow_form[&1])
      )
    end)
  end

  defp get_limit_date_range_warning(end_date)
       when end_date in ["", nil] do
    ""
  end

  defp get_limit_date_range_warning(end_date) when is_binary(end_date) do
    get_limit_date_range_warning(Date.from_iso8601!(end_date))
  end

  defp get_limit_date_range_warning(end_date) do
    today =
      DateTime.utc_now()
      |> DateTime.shift_zone!("America/New_York")
      |> DateTime.to_date()

    if Date.before?(end_date, today) do
      "*End date is in the past. Are you sure?"
    else
      ""
    end
  end
end
