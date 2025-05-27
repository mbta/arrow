defmodule Arrow.Shuttles.Shuttle do
  @moduledoc "schema for a shuttle for the db"
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Repo
  alias Arrow.Shuttles
  alias Arrow.Shuttles.ShapesUpload

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
    changeset =
      shuttle
      |> cast(attrs, [:shuttle_name, :disrupted_route_id, :status, :suffix])

    status = get_field(changeset, :status)

    changeset =
      if status == :active do
        cast_assoc(changeset, :routes, with: &route_changeset_with_validation/2)
      else
        cast_assoc(changeset, :routes, with: &Arrow.Shuttles.Route.changeset/2)
      end

    changeset
    |> validate_required([:shuttle_name, :status])
    |> validate_required_for(:status)
    |> foreign_key_constraint(:disrupted_route_id)
    |> unique_constraint(:shuttle_name)
  end

  # Helper function to pass shape coordinates to route changeset
  defp route_changeset_with_validation(route, attrs) do
    # IO.inspect(attrs, label: :attrs)
    # IO.inspect(route, label: :route)
    changeset = Arrow.Shuttles.Route.changeset(route, attrs)

    shape = get_route_shape(changeset)

    if shape do
      case get_shape_coordinates(shape) do
        {:ok, coordinates} when coordinates != :disabled ->
          Arrow.Shuttles.Route.changeset(route, attrs, coordinates)

        {:ok, :disabled} ->
          changeset

        {:error, reason} ->
          add_error(changeset, :shape_id, "unable to validate stop distances: #{reason}")
      end
    else
      changeset
    end
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

  @spec get_route_shape(Ecto.Changeset.t()) :: Shuttles.Shape.t() | nil
  defp get_route_shape(route_changeset) do
    case get_field(route_changeset, :shape) do
      %Shuttles.Shape{} = shape ->
        shape

      nil ->
        # Try to load from shape_id if shape isn't preloaded
        case get_field(route_changeset, :shape_id) do
          nil -> nil
          shape_id -> Repo.get(Shuttles.Shape, shape_id)
        end
    end
  end

  @spec get_shape_coordinates(Shuttles.Shape.t()) ::
          {:ok, [[float()]]} | {:ok, :disabled} | {:error, any()}
  defp get_shape_coordinates(shape) do
    case Shuttles.get_shapes_upload(shape) do
      {:ok, %Ecto.Changeset{} = changeset} ->
        coordinates =
          ShapesUpload.shapes_map_view(changeset)
          |> Map.get(:shapes)
          |> List.first()
          |> Map.get(:coordinates)

        {:ok, coordinates}

      {:ok, :disabled} ->
        {:ok, :disabled}

      error ->
        error
    end
  end
end
