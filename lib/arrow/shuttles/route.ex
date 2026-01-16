defmodule Arrow.Shuttles.Route do
  @moduledoc "schema for a shuttle route for the db"
  use Arrow.Schema
  import Ecto.Changeset

  alias Arrow.Repo
  alias Arrow.Shuttles
  alias Arrow.Shuttles.ShapesUpload

  @direction_0_desc_values [:Outbound, :South, :West]
  @direction_1_desc_values [:Inbound, :North, :East]

  def direction_desc_values, do: @direction_0_desc_values ++ @direction_1_desc_values

  def direction_desc_values(direction_id) when direction_id in [:"0", "0"],
    do: @direction_0_desc_values

  def direction_desc_values(direction_id) when direction_id in [:"1", "1"],
    do: @direction_1_desc_values

  typed_schema "shuttle_routes" do
    field :destination, :string
    field :direction_id, Ecto.Enum, values: [:"0", :"1"]
    field :direction_desc, Ecto.Enum, values: @direction_0_desc_values ++ @direction_1_desc_values
    field :waypoint, :string
    belongs_to :shuttle, Arrow.Shuttles.Shuttle
    belongs_to :shape, Arrow.Shuttles.Shape

    has_many :route_stops, Arrow.Shuttles.RouteStop,
      foreign_key: :shuttle_route_id,
      preload_order: [asc: :stop_sequence],
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(route, attrs, active? \\ false) do
    changeset =
      cast(route, attrs, [:direction_id, :direction_desc, :destination, :waypoint, :shape_id])

    shape = get_route_shape(changeset)

    {coordinates, error} =
      case get_shape_coordinates(shape, active?) do
        {:ok, coordinates} -> {coordinates, nil}
        {:error, error} -> {nil, error}
      end

    changeset
    |> then(&if error, do: add_error(&1, :shape_id, error), else: &1)
    |> cast_assoc(:route_stops,
      with: &Arrow.Shuttles.RouteStop.changeset(&1, &2, coordinates),
      sort_param: :route_stops_sort,
      drop_param: :route_stops_drop
    )
    |> validate_required([:direction_id, :direction_desc, :destination])
    |> assoc_constraint(:shape)
  end

  defp get_route_shape(route_changeset) do
    case get_field(route_changeset, :shape) do
      %Shuttles.Shape{} = shape ->
        shape

      nil ->
        case get_field(route_changeset, :shape_id) do
          nil -> nil
          shape_id -> Repo.get(Shuttles.Shape, shape_id)
        end
    end
  end

  defp get_shape_coordinates(nil, _), do: {:ok, nil}
  defp get_shape_coordinates(_, false), do: {:ok, nil}

  defp get_shape_coordinates(shape, _) do
    case Shuttles.get_shapes_upload(shape) do
      {:ok, %Ecto.Changeset{} = changeset} ->
        coordinates =
          changeset
          |> ShapesUpload.shapes_map_view()
          |> Map.get(:shapes)
          |> List.first()
          |> Map.get(:coordinates)

        {:ok, coordinates}

      {:ok, :disabled} ->
        {:ok, nil}

      error ->
        error
    end
  end
end
