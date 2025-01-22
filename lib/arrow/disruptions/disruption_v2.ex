defmodule Arrow.Disruptions.DisruptionV2 do
  @moduledoc """
  Represents a change to scheduled service for one of our transportions modes.

  See: https://github.com/mbta/gtfs_creator/blob/ab5aac52561027aa13888e4c4067a8de177659f6/gtfs_creator2/disruptions/disruption.py
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Arrow.Disruptions

  @type t :: %__MODULE__{
          title: String.t() | nil,
          mode: atom() | nil,
          is_active: boolean(),
          description: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          replacement_services:
            [Disruptions.ReplacementService.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "disruptionsv2" do
    field(:title, :string)
    field(:mode, Ecto.Enum, values: [:subway, :commuter_rail, :silver_line, :bus])
    field(:is_active, :boolean)
    field(:description, :string)

    has_many(:replacement_services, Disruptions.ReplacementService,
      foreign_key: :disruption_id,
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(disruption_v2, attrs \\ %{}) do
    disruption_v2
    |> cast(attrs, [:title, :is_active, :description])
    |> cast(attrs, [:mode], force_changes: true)
    |> cast_assoc(:replacement_services, with: &Disruptions.ReplacementService.changeset/2)
    |> validate_required([:title, :mode, :is_active])
  end
end
