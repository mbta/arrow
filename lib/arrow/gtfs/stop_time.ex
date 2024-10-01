defmodule Arrow.Gtfs.StopTime do
  @moduledoc """
  Represents a row from stop_times.txt.

  Changeset is intended for use only in CSV imports--
  table contents should be considered read-only otherwise.
  """
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          trip: Arrow.Gtfs.Trip.t() | Ecto.Association.NotLoaded.t(),
          stop_sequence: integer,
          arrival_time: Time.t(),
          departure_time: Time.t(),
          stop: Arrow.Gtfs.Stop.t() | Ecto.Association.NotLoaded.t(),
          stop_headsign: String.t() | nil,
          pickup_type: atom,
          drop_off_type: atom,
          timepoint: atom | nil,
          checkpoint: Arrow.Gtfs.Checkpoint.t() | Ecto.Association.NotLoaded.t() | nil,
          continuous_pickup: atom | nil,
          continuous_drop_off: atom | nil
        }

  @pickup_drop_off_types Enum.with_index([
                           :regularly_scheduled,
                           :not_available,
                           :phone_agency_to_arrange,
                           :coordinate_with_driver
                         ])

  @continuous_pickup_drop_off_types Enum.with_index([
                                      :continuous,
                                      :not_continuous,
                                      :phone_agency_to_arrange,
                                      :coordinate_with_driver
                                    ])

  @primary_key false

  schema "gtfs_stop_times" do
    belongs_to :trip, Arrow.Gtfs.Trip, primary_key: true
    field :stop_sequence, :integer, primary_key: true
    field :arrival_time, Arrow.Gtfs.Types.Time
    field :departure_time, Arrow.Gtfs.Types.Time
    belongs_to :stop, Arrow.Gtfs.Stop
    field :stop_headsign, :string
    field :pickup_type, Arrow.Gtfs.Types.Enum, values: @pickup_drop_off_types
    field :drop_off_type, Arrow.Gtfs.Types.Enum, values: @pickup_drop_off_types
    field :timepoint, Arrow.Gtfs.Types.Enum, values: Enum.with_index(~w[approximate exact]a)
    belongs_to :checkpoint, Arrow.Gtfs.Checkpoint
    field :continuous_pickup, Arrow.Gtfs.Types.Enum, values: @continuous_pickup_drop_off_types
    field :continuous_drop_off, Arrow.Gtfs.Types.Enum, values: @continuous_pickup_drop_off_types
  end

  def changeset(stop_time, attrs) do
    stop_time
    |> cast(
      attrs,
      ~w[trip_id stop_sequence arrival_time departure_time stop_id stop_headsign pickup_type drop_off_type timepoint checkpoint_id continuous_pickup continuous_drop_off]a
    )
    |> validate_required(
      ~w[trip_id stop_sequence arrival_time departure_time stop_id pickup_type drop_off_type]a
    )
    |> assoc_constraint(:trip)
    |> assoc_constraint(:stop)
    |> assoc_constraint(:checkpoint)
  end

  @impl Arrow.Gtfs.Importable
  def filenames, do: ["stop_times.txt"]

  @impl Arrow.Gtfs.Importable
  def import(unzip), do: Arrow.Gtfs.Importable.import_using_copy(__MODULE__, unzip)
end
