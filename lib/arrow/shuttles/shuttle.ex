defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Repo

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          status: :draft | :active | :inactive,
          shuttle_name: String.t(),
          suffix: String.t(),
          routes: [Arrow.Shuttles.Route.t()] | Ecto.Association.NotLoaded.t(),
          disrupted_route_id: String.t(),
          disrupted_route: Arrow.Gtfs.Route.t() | Ecto.Association.NotLoaded.t()
        }

  schema "shuttles" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :shuttle_name, :string
    field :suffix, :string

    has_many :routes, Arrow.Shuttles.Route, preload_order: [asc: :direction_id]
    has_many :replacement_services, ReplacementService
    belongs_to :disrupted_route, Arrow.Gtfs.Route, type: :string

    many_to_many :disruptions, DisruptionV2,
      join_through: ReplacementService,
      join_keys: [shuttle_id: :id, disruption_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shuttle, attrs, today \\ nil) do
    today =
      today ||
        DateTime.utc_now() |> DateTime.shift_zone!("America/New_York") |> DateTime.to_date()

    shuttle
    |> cast(attrs, [:shuttle_name, :disrupted_route_id, :status, :suffix])
    |> then(fn changeset ->
      cast_assoc(changeset, :routes,
        with: &Arrow.Shuttles.Route.changeset(&1, &2, get_field(changeset, :status) == :active)
      )
    end)
    |> validate_required([:shuttle_name, :status])
    |> validate_required_for(:status, today)
    |> foreign_key_constraint(:disrupted_route_id)
    |> unique_constraint(:shuttle_name)
  end

  defp validate_required_for(changeset, :status, today) do
    if get_field(changeset, :status) == :active,
      do: validate_for_active_status(changeset),
      else: validate_for_inactive_status(changeset, today)
  end

  defp validate_for_active_status(changeset) do
    routes = get_assoc(changeset, :routes)

    cond do
      routes |> Enum.map(&get_assoc(&1, :route_stops)) |> Enum.any?(&(length(&1) < 2)) ->
        add_error(changeset, :status, "must have at least two stops in each direction")

      routes
      |> Enum.map(&get_assoc(&1, :route_stops))
      |> Enum.any?(&route_stops_missing_time_to_next_stop?/1) ->
        add_error(
          changeset,
          :status,
          "all stops except the last in each direction must have a time to next stop"
        )

      routes
      |> Enum.any?(fn route -> is_nil(route.data.shape) end) ->
        add_error(
          changeset,
          :status,
          "all routes must have an associated shape"
        )

      true ->
        changeset
    end
  end

  defp validate_for_inactive_status(changeset, today) do
    shuttle_id = get_field(changeset, :id)

    active_parent_disruptions_with_active_replacement_services =
      if is_nil(shuttle_id) do
        []
      else
        from(
          d in DisruptionV2,
          as: :disruption,
          join: s in assoc(d, :shuttles),
          where: s.id == ^shuttle_id,
          where: d.is_active,
          # If any of an associated active disruption's replacement services (even those not using this shuttle)
          # have current or upcoming timeframes, then we can't safely deactivate the disruption.
          where:
            exists(
              from r in ReplacementService,
                where: r.disruption_id == parent_as(:disruption).id,
                where: r.end_date >= ^today
            ),
          select: d
        )
        |> Repo.all()
      end

    if active_parent_disruptions_with_active_replacement_services == [] do
      changeset
    else
      disruptions =
        active_parent_disruptions_with_active_replacement_services
        |> Enum.map_join(", ", &inspect(&1.title))

      add_error(
        changeset,
        :status,
        "can't deactivate: shuttle is in use by approved disruption(s) that have " <>
          "current or upcoming replacement services: #{disruptions}"
      )
    end
  end

  @spec route_stops_missing_time_to_next_stop?([Arrow.Shuttles.RouteStop.t()]) :: boolean()
  defp route_stops_missing_time_to_next_stop?(route_stops) do
    route_stops
    |> Enum.filter(&(&1.action not in [:replace, :delete]))
    |> Enum.sort_by(&get_field(&1, :stop_sequence))
    |> Enum.slice(0..-2//1)
    |> Enum.any?(&(&1 |> get_field(:time_to_next_stop) |> is_nil()))
  end
end
