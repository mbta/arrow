defmodule Arrow.Shuttle.ShapeUpload do
  @moduledoc "schema for shape upload"
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          filename: String.t(),
          shapes: list(Arrow.Shuttle.Shape.t())
        }

  embedded_schema do
    field :filename, :string
    embeds_many :shapes, Arrow.Shuttle.Shape
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

    with {:ok, shapes_kml} <- File.read(file.path),
         {:ok, shapes} <- parse_kml(shapes_kml) do
      {:ok, shapes}
    else
      {:error, exception} ->
        message =
          if is_atom(exception),
            do: :file.format_error(exception),
            else: Exception.message(exception)

        {:error,
         {"Failed to upload shapes from #{filename} because the provided xml was invalid",
          [message]}}
    end
  end

  @doc """
  Parses a KML shape into a map
  """
  @spec parse_kml(String.t()) :: {:ok, map} | {:error, any}
  def parse_kml(kml) do
    SAXMap.from_string(kml)
  end

  @doc """
  Parses one or many Shapes from a map of the KML/XML
  """
  @spec shapes_from_kml(map) :: {:ok, list(Arrow.Shuttle.Shape.t())} | {:error, any}
  def shapes_from_kml(saxy_shapes) do
    placemarks = saxy_shapes["kml"]["Folder"]["Placemark"]

    case placemarks do
      %{"LineString" => %{"coordinates" => coords}, "name" => name}
      when is_binary(coords) ->
        {:ok, [%{name: name, coordinates: String.split(coords)}]}

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
           %{name: pm["name"], coordinates: String.split(pm["LineString"]["coordinates"])}
         end)}
    end
  end
end
