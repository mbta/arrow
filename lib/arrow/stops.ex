defmodule Arrow.Stops do
  @moduledoc """
  The Stops context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Shuttle.Stop

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
  def delete_stop(%Stop{} = stop) do
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
