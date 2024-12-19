defmodule Arrow.Stops do
  @moduledoc """
  The Stops context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Shuttles.Stop

  @doc """
  Returns the list of stops.

  ## Examples

      iex> list_stops()
      [%Stop{}, ...]

  """
  def list_stops(params \\ %{}) do
    from(
      s in Stop,
      order_by: ^order_by(params["order_by"])
    )
    |> Repo.all()
  end

  @doc """
  Gets a single stop.

  Raises `Ecto.NoResultsError` if the Stop does not exist.

  ## Examples

      iex> get_stop!(123)
      %Stop{}

      iex> get_stop!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stop!(id), do: Repo.get!(Stop, id)

  @doc """
  Gets a single stop by stop_id.

  Returns nil if no stop exists with the given stop_id.

  ## Examples

      iex> get_stop_by_stop_id("123")
      %Stop{}

      iex> get_stop_by_stop_id("456")
      nil

  """
  def get_stop_by_stop_id(stop_id) do
    Repo.get_by(Stop, stop_id: stop_id)
  end

  @doc """
  Creates a stop.

  ## Examples

      iex> create_stop(%{field: value})
      {:ok, %Stop{}}

      iex> create_stop(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stop(attrs) do
    %Stop{}
    |> Stop.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stop.

  ## Examples

      iex> update_stop(stop, %{field: new_value})
      {:ok, %Stop{}}

      iex> update_stop(stop, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stop(%Stop{} = stop, attrs) do
    stop
    |> Stop.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stop.

  ## Examples

      iex> delete_stop(stop)
      {:ok, %Stop{}}

      iex> delete_stop(stop)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stop(%Arrow.Shuttles.Stop{} = stop) do
    Repo.delete(stop)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stop changes.

  ## Examples

      iex> change_stop(stop)
      %Ecto.Changeset{data: %Stop{}}

  """
  def change_stop(%Stop{} = stop, attrs \\ %{}) do
    Stop.changeset(stop, attrs)
  end

  @longitude_degrees_per_mile 1 / 54.6
  @latitude_degrees_per_mile 1 / 69
  def get_stops_within_mile(nil, {lat, lon}) do
    from(s in Stop,
      where:
        s.stop_lat <= ^lat + @latitude_degrees_per_mile and
          s.stop_lat >= ^lat - @latitude_degrees_per_mile and
          s.stop_lon <= ^lon + @longitude_degrees_per_mile and
          s.stop_lon >= ^lon - @latitude_degrees_per_mile
    )
    |> Repo.all()
  end

  @doc """
  Get other Arrow shuttle stops within one mile of a given longitude and latitude, excluding 
  the stop identified by `arrow_stop_id`

  ## Examples
      iex> Arrow.Stops.get_stops_within_mile("123", {42.3774, -72.1189})
      [%Arrow.Shuttles.Stop%{}, ...]

      iex> Arrow.Stops.Stop.get_stops_within_mile(nil, {42.3774, -72.1189})
      [%Arrow.Shuttles.Stop{}, ...]
  """
  @spec get_stops_within_mile(String.t() | nil, {float(), float()}) :: list(Arrow.Shuttles.Stop.t())
  def get_stops_within_mile(stop_id, {lat, lon}) do
    from(s in Stop,
      where:
        s.stop_id != ^stop_id and
          s.stop_lat <= ^lat + @latitude_degrees_per_mile and
          s.stop_lat >= ^lat - @latitude_degrees_per_mile and
          s.stop_lon <= ^lon + @longitude_degrees_per_mile and
          s.stop_lon >= ^lon - @latitude_degrees_per_mile
    )
    |> Repo.all()
  end

  defp order_by("stop_id_desc"), do: [desc: :stop_id]
  defp order_by("stop_id_asc"), do: [asc: :stop_id]
  defp order_by("stop_name_desc"), do: [desc: :stop_name]
  defp order_by("stop_name_asc"), do: [asc: :stop_name]
  defp order_by("stop_desc_desc"), do: [desc: :stop_desc]
  defp order_by("stop_desc_asc"), do: [asc: :stop_desc]
  defp order_by("platform_code_desc"), do: [desc: :platform_code]
  defp order_by("platform_code_asc"), do: [asc: :platform_code]
  defp order_by("platform_name_desc"), do: [desc: :platform_name]
  defp order_by("platform_name_asc"), do: [asc: :platform_name]
  defp order_by("stop_lat_desc"), do: [desc: :stop_lat]
  defp order_by("stop_lat_asc"), do: [asc: :stop_lat]
  defp order_by("stop_lon_desc"), do: [desc: :stop_lon]
  defp order_by("stop_lon_asc"), do: [asc: :stop_lon]
  defp order_by("stop_address_desc"), do: [desc: :stop_address]
  defp order_by("stop_address_asc"), do: [asc: :stop_address]
  defp order_by("zone_id_desc"), do: [desc: :zone_id]
  defp order_by("zone_id_asc"), do: [asc: :zone_id]
  defp order_by("level_id_desc"), do: [desc: :level_id]
  defp order_by("level_id_asc"), do: [asc: :level_id]
  defp order_by("parent_station_desc"), do: [desc: :parent_station]
  defp order_by("parent_station_asc"), do: [asc: :parent_station]
  defp order_by("municipality_desc"), do: [desc: :municipality]
  defp order_by("municipality_asc"), do: [asc: :municipality]
  defp order_by("on_street_desc"), do: [desc: :on_street]
  defp order_by("on_street_asc"), do: [asc: :on_street]
  defp order_by("at_street_desc"), do: [desc: :at_street]
  defp order_by("at_street_asc"), do: [asc: :at_street]
  defp order_by("updated_at_desc"), do: [desc: :updated_at]
  defp order_by("updated_at_asc"), do: [asc: :updated_at]
  defp order_by(_), do: []
end
