defmodule Arrow.Disruptions.ReplacementService do
  @moduledoc """
  Represents replacement service associated with a disruption

  See related: https://github.com/mbta/gtfs_creator/blob/ab5aac52561027aa13888e4c4067a8de177659f6/gtfs_creator2/disruptions/activated_shuttles.py
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions.DisruptionV2
  alias Arrow.Shuttles.Shuttle

  @type t :: %__MODULE__{
          reason: String.t() | nil,
          start_date: Date.t() | nil,
          end_date: Date.t() | nil,
          source_workbook_data: map(),
          source_workbook_filename: String.t(),
          disruption: DisruptionV2.t() | Ecto.Association.NotLoaded.t(),
          shuttle: Shuttle.t() | Ecto.Association.NotLoaded.t()
        }

  schema "replacement_services" do
    field :reason, :string
    field :start_date, :date
    field :end_date, :date
    field :source_workbook_data, :map
    field :source_workbook_filename, :string
    belongs_to :disruption, DisruptionV2
    belongs_to :shuttle, Shuttle

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(replacement_service, attrs) do
    replacement_service
    |> cast(attrs, [
      :reason,
      :start_date,
      :end_date,
      :source_workbook_data,
      :source_workbook_filename,
      :shuttle_id,
      :disruption_id
    ])
    |> validate_required([
      :start_date,
      :end_date,
      :source_workbook_data,
      :source_workbook_filename
    ])
    |> validate_start_date_before_end_date()
    |> assoc_constraint(:shuttle)
    |> assoc_constraint(:disruption)
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(t())) :: Ecto.Changeset.t(t())
  defp validate_start_date_before_end_date(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      not (Date.compare(start_date, end_date) == :lt) ->
        add_error(changeset, :start_date, "start date should be before end date")

      true ->
        changeset
    end
  end
end
