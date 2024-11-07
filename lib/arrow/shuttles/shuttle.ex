defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset

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
    fields = [:status]

    case status do
      :active ->
        message = "can't be set to active when required fields are missing"

        %{
          changeset
          | errors:
              Enum.map(
                fields,
                &{&1, {message, [validation: :required]}}
              ),
            valid?: false
        }

      _ ->
        changeset
    end
  end
end
