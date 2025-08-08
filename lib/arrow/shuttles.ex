defmodule Arrow.Shuttles do
  @moduledoc """
  The Shuttles context.
  """

  alias Ecto.Multi
  import Ecto.Query, warn: false

  alias Arrow.OpenRouteServiceAPI
  alias Arrow.OpenRouteServiceAPI.DirectionsResponse
  alias Arrow.OpenRouteServiceAPI.ErrorResponse
  alias Arrow.Repo
  alias ArrowWeb.ErrorHelpers

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Gtfs.Route, as: GtfsRoute
  alias Arrow.Gtfs.Stop, as: GtfsStop
  alias Arrow.Shuttles.KML
  alias Arrow.Shuttles.RouteStop
  alias Arrow.Shuttles.Shape
  alias Arrow.Shuttles.ShapesUpload
  alias Arrow.Shuttles.ShapeUpload
  alias Arrow.Shuttles.Stop

  require Logger

  @preloads [routes: [:shape, route_stops: [:stop, :gtfs_stop]]]

  @doc """
  Returns the list of shapes.

  ## Examples

      iex> list_shapes()
      [%Shape{}, ...]

  """
  def list_shapes do
    Repo.all(Shape)
  end

  @doc """
  Gets a single shape.

  Raises `Ecto.NoResultsError` if the Shape does not exist.

  ## Examples

      iex> get_shape!(123)
      %Shape{}

      iex> get_shape!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shape!(id), do: Repo.get!(Shape, id)

  @doc """
  Gets a single shape by name.

  Raises `Ecto.NoResultsError` if the Shape does not exist.

  ## Examples

      iex> get_shape_by_name!("Shape1")
      %Shape{}

      iex> get_shape_by_name!("Shape2")
      ** (Ecto.NoResultsError)

  """
  def get_shape_by_name!(name), do: Repo.get_by!(Shape, name: name)

  @doc """
  Gets the shapes specifiied by a list of ids. Does not raise if any of the ids are missing,
  meaning the resulting list may be shorter than the input list.
  """
  def get_shapes(ids) do
    Repo.all(from s in Shape, where: s.id in ^ids)
  end

  @doc """
  Gets a shapes upload struct associated with a given shape.

  ## Examples

      iex> get_shapes_upload(%Shape{})
      {:ok, %Ecto.Changeset{data: %ShapesUpload{}}
  """
  def get_shapes_upload(%Shape{} = shape) do
    with true <- Application.get_env(:arrow, :shape_storage_enabled?),
         {:ok, %{body: shapes_kml}} <- get_shape_file(shape),
         {:ok, parsed_shapes} <- ShapesUpload.parse_kml(shapes_kml),
         {:ok, shapes} <- ShapesUpload.shapes_from_kml(parsed_shapes) do
      {:ok, ShapesUpload.changeset(%ShapesUpload{}, %{filename: shape.name, shapes: shapes})}
    else
      false -> {:ok, :disabled}
      error -> error
    end
  end

  defp get_shape_file(shape) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    {request_module, request_func} = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? do
      get_request = ExAws.S3.get_object(shape.bucket, shape.path)
      apply(request_module, request_func, [get_request])
    else
      {:ok, :disabled}
    end
  end

  @spec create_shapes(any()) :: {:error, {<<_::224>>, list()}} | {:ok, list()}
  @doc """
  Creates shapes.

  """
  def create_shapes(shapes) do
    changesets = Enum.map(shapes, fn shape -> create_shape(shape) end)

    case Enum.all?(changesets, fn changeset -> Kernel.match?({:ok, _shape}, changeset) end) do
      true ->
        {:ok, changesets}

      _ ->
        errors =
          changesets
          |> Enum.filter(fn changeset -> Kernel.match?({:error, _}, changeset) end)
          |> Enum.map(&handle_create_error/1)

        {:error, {"Failed to upload some shapes", errors}}
    end
  end

  def handle_create_error({_, message}) when is_binary(message) do
    message
  end

  def handle_create_error({_, %Ecto.Changeset{} = changeset}) do
    "#{ErrorHelpers.changeset_error_messages(changeset)} #{changeset.params["name"]}"
  end

  @doc """
  Creates a shape.

  ## Examples

      iex> create_shape(%{field: value})
      {:ok, %Shape{}}

      iex> create_shape(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shape(attrs, validate_name \\ true) do
    with {:ok, attrs} <- Shape.validate_and_enforce_name(attrs, validate_name),
         nil <- Repo.get_by(Shape, name: attrs.name),
         {:ok, shape_with_kml} <- create_shape_kml(attrs),
         {:ok, new_attrs} <- upload_shape_file(shape_with_kml) do
      do_create_shape(Enum.into(new_attrs, attrs))
    else
      %Shape{name: name} ->
        {:error, "Shape #{name} already exists, delete the shape to save a new one"}

      {:error, :already_exists} ->
        {:error,
         "File for shape #{attrs.name} already exists, delete the shape to save a new one"}

      {:error, e} ->
        {:error, e}
    end
  end

  defp do_create_shape(attrs) do
    %Shape{}
    |> Shape.changeset(attrs)
    |> Repo.insert()
  end

  def create_shape_kml(%{name: _name, coordinates: _coordinates} = attrs) do
    kml = %KML{xmlns: "http://www.opengis.net/kml/2.2", Folder: attrs}
    shape_kml = Saxy.Builder.build(kml)
    content = Saxy.encode!(shape_kml, version: "1.0", encoding: "UTF-8")
    {:ok, Enum.into(%{content: content}, attrs)}
  end

  def create_shape_kml(attrs) do
    {:error, ShapeUpload.changeset(%ShapeUpload{}, attrs)}
  end

  defp upload_shape_file(%{name: name, content: content}) do
    prefix = Application.get_env(:arrow, :shape_storage_prefix)
    bucket = Application.get_env(:arrow, :shape_storage_bucket)
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    prefix_env = Application.get_env(:arrow, :shape_storage_prefix_env)
    request_fn = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? and prefix_env != nil do
      filename = "#{name}.kml"
      path = get_shape_upload_path(filename)

      case do_upload_shape(content, bucket, path, request_fn) do
        error = {:error, _} -> error
        {:ok, _} -> {:ok, %{bucket: bucket, prefix: prefix, path: path}}
      end
    else
      {:ok, %{bucket: "disabled", prefix: "disabled", path: "disabled"}}
    end
  end

  defp do_upload_shape(content, bucket, remote_path, request_fn) do
    {request_module, request_func} = request_fn
    # Check if file exists already:
    check_request = ExAws.S3.list_objects_v2(bucket, prefix: remote_path)
    {:ok, check} = apply(request_module, request_func, [check_request])

    if length(check.body.contents) > 0 do
      {:error, :already_exists}
    else
      upload_request = ExAws.S3.put_object(bucket, remote_path, content)
      {:ok, _} = apply(request_module, request_func, [upload_request])
    end
  end

  defp get_shape_upload_path(filename) do
    prefix_env = Application.get_env(:arrow, :shape_storage_prefix_env)
    s3_prefix = Application.get_env(:arrow, :shape_storage_prefix)

    username_prefix =
      if Application.get_env(:arrow, :use_username_prefix?) do
        {username, _} = System.cmd("whoami", [])
        String.trim(username)
      end

    [prefix_env, username_prefix, s3_prefix, filename]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
  end

  defp delete_shape_file(shape) do
    enabled? = Application.get_env(:arrow, :shape_storage_enabled?)
    {request_module, request_func} = Application.get_env(:arrow, :shape_storage_request_fn)

    if enabled? do
      delete_request = ExAws.S3.delete_object(shape.bucket, shape.path)
      apply(request_module, request_func, [delete_request])
    else
      {:ok, :disabled}
    end
  end

  @doc """
  Deletes a shape.

  ## Examples

      iex> delete_shape(shape)
      {:ok, %Shape{}}

      iex> delete_shape(shape)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shape(%Shape{} = shape) do
    case shuttles_using_shape(shape) do
      [] ->
        Repo.transaction(fn ->
          {:ok, shape} = Repo.delete(shape)
          {:ok, _} = delete_shape_file(shape)

          shape
        end)

      shuttles ->
        {:error,
         "Shape is used by the following shuttle(s) and cannot be deleted: #{Enum.map_join(shuttles, ", ", &inspect(&1.shuttle_name))}"}
    end
  end

  @doc """
  Returns a list of shuttles using the given shape
  """
  def shuttles_using_shape(%Shape{} = shape) do
    from(s in Arrow.Shuttles.Shuttle,
      join: r in assoc(s, :routes),
      where: r.shape_id == ^shape.id,
      distinct: s,
      select: s
    )
    |> Repo.all()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shape changes.

  ## Examples

      iex> change_shape(shape)
      %Ecto.Changeset{data: %Shape{}}

  """
  def change_shape(%Shape{} = shape, attrs \\ %{}) do
    Shape.changeset(shape, attrs)
  end

  alias Arrow.Shuttles.Shuttle

  @doc """
  Returns the list of shuttles.

  ## Examples

      iex> list_shuttles()
      [%Shuttle{}, ...]

  """
  def list_shuttles do
    Repo.all(Shuttle) |> Repo.preload(@preloads)
  end

  @doc """
  Gets a single shuttle.

  Raises `Ecto.NoResultsError` if the Shuttle does not exist.

  ## Examples

      iex> get_shuttle!(123)
      %Shuttle{}

      iex> get_shuttle!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shuttle!(id) do
    Repo.get!(Shuttle, id) |> Repo.preload(@preloads) |> populate_display_stop_ids()
  end

  @doc """
  Creates a shuttle.

  ## Examples

      iex> create_shuttle(%{field: value})
      {:ok, %Shuttle{}}

      iex> create_shuttle(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shuttle(attrs \\ %{}) do
    created_shuttle =
      %Shuttle{}
      |> Shuttle.changeset(attrs)
      |> Repo.insert()

    case created_shuttle do
      {:ok, shuttle} -> {:ok, shuttle |> Repo.preload(@preloads) |> populate_display_stop_ids()}
      err -> err
    end
  end

  @doc """
  Updates a shuttle.

  ## Special behavior for non-active status

  If the shuttle is set to a non-active status, the outcome depends on
  properties of the disruptions using the shuttle.

  For each disruption that uses this deactivated shuttle in a replacement
  service:

  | Disruption status | Disruption's Replacement Services contain... | Outcome                                           |
  | ----------------- | -------------------------------------------- | ------------------------------------------------- |
  | inactive          | any                                          | Shuttle update continues.                         |
  | active            | only with past timeframes                    | Shuttle update continues; disruption deactivates. |
  | active            | 1 or more with current/future timeframe(s)   | Shuttle update aborts.                            |

  The shuttle update and any necessary disruption deactivations are performed in
  a transaction.

  On success, returns a tuple containing the updated shuttle and the disruptions
  that were deactivated, if any.

  ## Examples

      iex> update_shuttle(shuttle, %{field: new_value})
      {:ok, %Shuttle{}, [%DisruptionV2{}, ...]}

      iex> update_shuttle(shuttle, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shuttle(%Shuttle{} = shuttle, attrs, today \\ nil) do
    today =
      today ||
        DateTime.utc_now() |> DateTime.shift_zone!("America/New_York") |> DateTime.to_date()

    Multi.new()
    |> Multi.update(:shuttle, fn _ -> Shuttle.changeset(shuttle, attrs, today) end)
    |> Multi.run(:deactivate_past_disruptions, fn
      _repo, %{shuttle: %Shuttle{status: :active}} -> {:ok, []}
      _repo, %{shuttle: shuttle} -> deactivate_past_disruptions(shuttle)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{shuttle: shuttle, deactivate_past_disruptions: disruptions}} ->
        shuttle = shuttle |> Repo.preload(@preloads) |> populate_display_stop_ids()
        {:ok, shuttle, disruptions}

      {:error, :shuttle, changeset, _} ->
        {:error, changeset}
    end
  end

  @spec deactivate_past_disruptions(Shuttle.t()) :: {:ok, [DisruptionV2.t()]}
  defp deactivate_past_disruptions(%Shuttle{id: shuttle_id, status: status})
       when status != :active do
    # Since this code runs inside a transaction and is reached only if the
    # shuttle changeset passed validations, we know that any active disruptions
    # associated with this shuttle do not have any current or upcoming
    # replacement service timeframes, and can be safely deactivated.
    {_, deactivated_disruptions} =
      from(
        d in DisruptionV2,
        as: :disruption,
        join: s in assoc(d, :shuttles),
        where: s.id == ^shuttle_id,
        where: d.is_active,
        select: d
      )
      |> Repo.update_all(set: [is_active: false, updated_at: DateTime.utc_now()])

    if deactivated_disruptions != [] do
      disruption_ids = Enum.map_join(deactivated_disruptions, ",", & &1.id)

      Logger.info(
        "deactivated_past_disruptions_while_deactivating_shuttle " <>
          "shuttle_id=#{shuttle_id} disruption_ids=#{disruption_ids}"
      )
    end

    {:ok, deactivated_disruptions}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shuttle changes.

  ## Examples

      iex> change_shuttle(shuttle)
      %Ecto.Changeset{data: %Shuttle{}}

  """
  def change_shuttle(%Shuttle{} = shuttle, attrs \\ %{}) do
    Shuttle.changeset(shuttle, attrs)
  end

  @spec populate_display_stop_ids(map()) :: map()
  def populate_display_stop_ids(shuttle) do
    update_in(
      shuttle,
      [Access.key(:routes), Access.all(), Access.key(:route_stops), Access.all()],
      fn route_stop -> %{route_stop | display_stop_id: get_display_stop_id(route_stop)} end
    )
  end

  @spec get_display_stop_id(RouteStop.t()) :: String.t()
  def get_display_stop_id(%RouteStop{stop: %Stop{stop_id: stop_id}}), do: stop_id

  def get_display_stop_id(%RouteStop{gtfs_stop_id: gtfs_stop_id}), do: gtfs_stop_id

  @spec get_stop_coordinates(RouteStop.t() | Stop.t() | GtfsStop.t()) ::
          {:ok, map()} | {:error, any}
  def get_stop_coordinates(%RouteStop{display_stop: nil, display_stop_id: nil}) do
    {:error, "Incomplete stop data, please check your input"}
  end

  def get_stop_coordinates(%RouteStop{id: nil, display_stop: nil, display_stop_id: id}) do
    {:error, "Missing lat/lon data for stop #{id}"}
  end

  def get_stop_coordinates(%RouteStop{id: nil, display_stop: display_stop, display_stop_id: id}) do
    if id,
      do: get_stop_coordinates(display_stop),
      else: {:error, "Missing id for stop"}
  end

  def get_stop_coordinates(%RouteStop{
        display_stop: %Stop{} = display_stop,
        display_stop_id: _display_stop_id
      }) do
    get_stop_coordinates(display_stop)
  end

  def get_stop_coordinates(%RouteStop{
        display_stop: %GtfsStop{} = display_stop,
        display_stop_id: _display_stop_id
      }) do
    get_stop_coordinates(display_stop)
  end

  def get_stop_coordinates(%RouteStop{gtfs_stop: stop, stop: nil}) do
    stop =
      if Ecto.assoc_loaded?(stop),
        do: stop,
        else: Arrow.Repo.preload(stop, :gtfs_stop, force: true)

    get_stop_coordinates(stop)
  end

  def get_stop_coordinates(%RouteStop{gtfs_stop: nil, stop: stop}) do
    stop =
      if Ecto.assoc_loaded?(stop),
        do: stop,
        else: Arrow.Repo.preload(stop, :stop, force: true)

    get_stop_coordinates(stop)
  end

  def get_stop_coordinates(%GtfsStop{lat: lat, lon: lon}) do
    {:ok, %{lat: lat, lon: lon}}
  end

  def get_stop_coordinates(%Stop{stop_lat: lat, stop_lon: lon}) do
    {:ok, %{lat: lat, lon: lon}}
  end

  def get_stop_coordinates(stop) do
    {:error, "Missing lat/lon data for stop #{inspect(stop)}"}
  end

  @spec get_travel_times(list(%{lat: number(), lon: number()})) ::
          {:ok, list(number())} | {:error, any()}
  def get_travel_times(coordinates) do
    coordinates = coordinates |> Enum.map(&Map.new(&1, fn {k, v} -> {to_string(k), v} end))

    case OpenRouteServiceAPI.directions(coordinates) do
      {:ok, %DirectionsResponse{segments: segments}} ->
        {:ok, segments |> Enum.map(&round(&1.duration))}

      {:error, %ErrorResponse{type: :no_route}} ->
        {:error, "Unable to retrieve estimates: no route between stops found"}

      {:error, %ErrorResponse{type: :unknown}} ->
        {:error, "Unable to retrieve estimates: unknown error"}
    end
  end

  def list_disruptable_routes do
    query = from(r in GtfsRoute, where: r.type in [:light_rail, :heavy_rail])
    Repo.all(query)
  end

  @doc """
  Given a stop ID, returns either an Arrow-created stop, or a
  stop from GTFS. Prefers the Arrow-created stop if both are
  present.
  """
  @spec stop_or_gtfs_stop_for_stop_id(String.t() | nil) :: Stop.t() | GtfsStop.t() | nil
  def stop_or_gtfs_stop_for_stop_id(nil), do: nil

  def stop_or_gtfs_stop_for_stop_id(id) do
    case Repo.get_by(Stop, stop_id: id) do
      nil -> Repo.get(GtfsStop, id)
      stop -> stop
    end
  end

  @doc """
  Gets a displayable name for a stop or GTFS stop, preferring the
  description if available but falling back on name if needed.
  """
  @spec stop_display_name(Stop.t() | GtfsStop.t()) :: String.t()
  def stop_display_name(%Stop{stop_desc: stop_desc, stop_name: stop_name}),
    do: if(stop_desc != "", do: stop_desc, else: stop_name)

  def stop_display_name(%GtfsStop{desc: desc, name: name}), do: desc || name

  @spec stops_or_gtfs_stops_by_search_string(String.t()) :: [Stop.t() | GtfsStop.t()]
  def stops_or_gtfs_stops_by_search_string(string) do
    sanitized_string = Arrow.Util.sanitized_string_for_sql_like(string)

    stops_query =
      from(s in Stop,
        where:
          ilike(s.stop_id, ^sanitized_string) or ilike(s.stop_desc, ^sanitized_string) or
            ilike(s.stop_name, ^sanitized_string)
      )

    gtfs_stops_query =
      from(g in GtfsStop,
        where:
          g.vehicle_type == :bus and g.location_type == :stop_platform and
            (ilike(g.id, ^sanitized_string) or ilike(g.desc, ^sanitized_string) or
               ilike(g.name, ^sanitized_string))
      )

    matching_stops = Repo.all(stops_query)

    arrow_stop_ids = matching_stops |> Enum.map(& &1.stop_id) |> MapSet.new()

    matching_gtfs_stops =
      gtfs_stops_query |> Repo.all() |> Enum.filter(&(!MapSet.member?(arrow_stop_ids, &1.id)))

    Enum.concat(matching_stops, matching_gtfs_stops)
  end

  def shuttles_by_search_string(string) do
    sanitized_string = Arrow.Util.sanitized_string_for_sql_like(string)

    shuttles_query = from(s in Shuttle, where: ilike(s.shuttle_name, ^sanitized_string))

    Repo.all(shuttles_query)
  end
end
