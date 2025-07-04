defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Repo

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          status: :draft | :active | :inactive,
          shuttle_name: String.t(),
          disrupted_route_id: String.t(),
          suffix: String.t()
        }

  schema "shuttles" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :shuttle_name, :string
    field :disrupted_route_id, :string
    field :suffix, :string

    has_many :routes, Arrow.Shuttles.Route, preload_order: [asc: :direction_id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shuttle, attrs) do
    shuttle
    |> cast(attrs, [:shuttle_name, :disrupted_route_id, :status, :suffix])
    |> then(fn changeset ->
      cast_assoc(changeset, :routes,
        with: &Arrow.Shuttles.Route.changeset(&1, &2, get_field(changeset, :status) == :active)
      )
    end)
    |> validate_required([:shuttle_name, :status])
    |> validate_required_for(:status)
    |> foreign_key_constraint(:disrupted_route_id)
    |> unique_constraint(:shuttle_name)
  end

  defp validate_required_for(changeset, :status) do
    # Placeholder validation until form is complete
    status = get_field(changeset, :status)
    # Set error on status field for now

    case status do
      :active ->
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

      _ ->
        id = get_field(changeset, :id)

        replacement_services =
          if is_nil(id) do
            []
          else
            Repo.all(from r in ReplacementService, where: r.shuttle_id == ^id)
          end

        if length(replacement_services) > 0 do
          add_error(
            changeset,
            :status,
            "cannot set to a non-active status while in use as a replacement service"
          )
        else
          changeset
        end
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
