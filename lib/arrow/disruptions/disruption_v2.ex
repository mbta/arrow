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
          limits: [Arrow.Disruptions.Limit.t()] | Ecto.Association.NotLoaded.t(),
          replacement_services:
            [Disruptions.ReplacementService.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "disruptionsv2" do
    field :title, :string
    field :mode, Ecto.Enum, values: [:subway, :commuter_rail, :silver_line, :bus]
    field :is_active, :boolean
    field :description, :string

    has_many :limits, Arrow.Disruptions.Limit,
      foreign_key: :disruption_id,
      on_replace: :delete

    has_many :replacement_services, Disruptions.ReplacementService,
      foreign_key: :disruption_id,
      on_replace: :delete

    has_many :hastus_exports, Arrow.Hastus.Export,
      foreign_key: :disruption_id,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(disruption_v2, attrs \\ %{}) do
    disruption_v2
    |> cast(attrs, [:title, :is_active, :description])
    |> cast(attrs, [:mode], force_changes: true)
    |> cast_assoc(:limits, with: &Arrow.Disruptions.Limit.changeset/2)
    |> cast_assoc(:replacement_services, with: &Disruptions.ReplacementService.changeset/2)
    |> validate_required([:title, :mode, :is_active])
  end

  def new(attrs \\ %{}) do
    %__MODULE__{limits: [], replacement_services: [], mode: :subway}
    |> struct!(attrs)
  end

  @spec route(String.t()) :: atom() | nil
  def route("Blue"), do: :blue_line
  def route("Orange"), do: :orange_line
  def route("Red"), do: :red_line
  def route("Mattapan"), do: :mattapan_line
  def route("Green-B"), do: :green_line_b
  def route("Green-C"), do: :green_line_c
  def route("Green-D"), do: :green_line_d
  def route("Green-E"), do: :green_line_e
  def route(_), do: nil
end
