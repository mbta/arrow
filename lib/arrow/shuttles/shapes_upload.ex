defmodule Arrow.Shuttles.ShapesUpload do
  @moduledoc "schema for shapes upload"
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          filename: String.t(),
          shapes: list(Arrow.Shuttles.ShapeUpload.t())
        }

  embedded_schema do
    field :filename, :string
    embeds_many :shapes, Arrow.Shuttles.ShapeUpload
  end

  @doc false
  def changeset(shape, attrs) do
    shape
    |> cast(attrs, [:filename])
    |> cast_embed(:shapes)
  end

  def parse_kml_from_file(shape_upload) do
    file = shape_upload["filename"]
    filename = file.filename

    with {:ok, shapes_kml} <- read_file(file.path),
         {:ok, shapes} <- parse_kml(shapes_kml) do
      {:ok, shapes}
    else
      {:error, reason} ->
        {:error,
         {"Failed to upload shapes from #{filename} because the provided xml was invalid",
          [reason]}}
    end
  end

  @doc """
  Reads a file from a file input
  """
  def read_file(path) do
    case File.read(path) do
      {:ok, contents} -> {:ok, contents}
      {:error, exception} -> {:error, :file.format_error(exception)}
    end
  end

  @doc """
  Parses a KML shape into a map
  """
  @spec parse_kml(String.t()) :: {:ok, map} | {:error, exception :: Saxy.ParseError.t()}
  def parse_kml(kml) do
    case SAXMap.from_string(kml) do
      {:ok, shapes} -> {:ok, shapes}
      {:error, exception} -> {:error, Saxy.ParseError.message(exception)}
    end
  end

  @spec process_coordinates(String.t()) :: [String.t()]
  def process_coordinates(coordinates) do
    coordinates
    |> String.split()
    |> Enum.dedup()
  end

  @doc """
  Parses one or many Shapes from a map of the KML/XML
  """
  @spec shapes_from_kml(map) :: {:ok, list(Arrow.Shuttles.ShapeUpload.t())} | {:error, any}
  def shapes_from_kml(saxy_shapes) do
    placemarks = saxy_shapes["kml"]["Folder"]["Placemark"]

    case placemarks do
      %{"LineString" => %{"coordinates" => coords}, "name" => name}
      when is_binary(coords) ->
        {:ok, [%{name: name, coordinates: process_coordinates(coords)}]}

      %{"LineString" => %{"coordinates" => nil}, "name" => _name} ->
        error =
          {"Failed to parse shape from kml, no coordinates were found. Check your whitespace.",
           [inspect(placemarks)]}

        {:error, error}

      _ ->
        # Multiple placemarks, only capture Placemarks with LineString
        placemarks = Enum.filter(placemarks, fn pm -> pm["LineString"] end)

        {:ok,
         Enum.map(placemarks, fn pm ->
           %{name: pm["name"], coordinates: process_coordinates(pm["LineString"]["coordinates"])}
         end)}
    end
  end

  def shapes_map_view(%__MODULE__{shapes: shapes}) do
    %{shapes: Enum.map(shapes, &shape_map_view/1)}
  end

  def shapes_map_view(%{params: %{"shapes" => shapes}}) do
    %{shapes: Enum.map(shapes, &shape_map_view/1)}
  end

  def shapes_map_view({:ok, :disabled}), do: %{}

  def shapes_map_view(_), do: %{error: "Failed to load shape file"}

  defp shape_map_view(%{coordinates: coordinates, name: name}) do
    %{
      coordinates: map_coordinates(coordinates),
      name: name
    }
  end

  defp map_coordinates(coordinates) do
    Enum.map(coordinates, &process_coordinate_pair/1)
  end

  defp process_coordinate_pair(coordinate_pair) do
    coordinate_pair
    |> String.split(",")
    |> Enum.map(&String.to_float/1)
    |> Enum.reverse()
  end
end
