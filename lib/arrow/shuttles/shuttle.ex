defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset

  @type id :: integer
  @type t :: %__MODULE__{
          id: id,
          status: :draft | :active | :inactive,
          shuttle_name: String.t(),
          disrupted_route_id: String.t()
        }

  schema "shuttles" do
    field :status, Ecto.Enum, values: [:draft, :active, :inactive]
    field :shuttle_name, :string
    field :disrupted_route_id, :string

    has_many :routes, Arrow.Shuttles.Route, preload_order: [asc: :direction_id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shuttle, attrs) do
    shuttle
    |> cast(attrs, [:shuttle_name, :disrupted_route_id, :status])
    |> cast_assoc(:routes, with: &Arrow.Shuttles.Route.changeset/2)
    |> validate_required([:shuttle_name, :status])
    |> validate_required_for(:status)
    |> foreign_key_constraint(:disrupted_route_id)
    |> unique_constraint(:shuttle_name)
  end

  def validate_required_for(changeset, :status) do
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
          |> Enum.any?(fn route_stops ->
            route_stops
            |> Enum.slice(0..-2//1)
            |> Enum.any?(&(&1 |> get_field(:time_to_next_stop) |> is_nil()))
          end) ->
            add_error(
              changeset,
              :status,
              "all stops except the last in each direction must have a time to next stop"
            )

          true ->
            changeset
        end

      _ ->
        changeset
    end
  end
end
