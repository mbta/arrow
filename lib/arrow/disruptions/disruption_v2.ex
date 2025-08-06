defmodule Arrow.Disruptions.DisruptionV2 do
  @moduledoc """
  Represents a change to scheduled service for one of our transportions modes.

  See: https://github.com/mbta/gtfs_creator/blob/ab5aac52561027aa13888e4c4067a8de177659f6/gtfs_creator2/disruptions/disruption.py
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Arrow.Disruptions.Limit
  alias Arrow.Disruptions.ReplacementService
  alias Arrow.Hastus.Export
  alias Arrow.Repo
  alias Arrow.Shuttles.Shuttle

  @type t :: %__MODULE__{
          title: String.t() | nil,
          mode: atom() | nil,
          is_active: boolean(),
          description: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil,
          limits: [Limit.t()] | Ecto.Association.NotLoaded.t(),
          replacement_services: [ReplacementService.t()] | Ecto.Association.NotLoaded.t(),
          hastus_exports: [Export.t()] | Ecto.Association.NotLoaded.t(),
          shuttles: [Shuttle.t()] | Ecto.Association.NotLoaded.t()
        }

  schema "disruptionsv2" do
    field :title, :string
    field :mode, Ecto.Enum, values: [:subway, :commuter_rail, :silver_line, :bus]
    field :is_active, :boolean
    field :description, :string

    has_many :limits, Limit,
      foreign_key: :disruption_id,
      on_replace: :delete

    has_many :replacement_services, ReplacementService,
      foreign_key: :disruption_id,
      on_replace: :delete

    has_many :hastus_exports, Export,
      foreign_key: :disruption_id,
      on_replace: :delete

    many_to_many :shuttles, Shuttle,
      join_through: ReplacementService,
      join_keys: [disruption_id: :id, shuttle_id: :id]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(disruption_v2, attrs \\ %{}) do
    disruption_v2
    |> cast(attrs, [:title, :is_active, :description])
    |> cast(attrs, [:mode], force_changes: true)
    |> cast_assoc(:limits, with: &Limit.changeset/2)
    |> cast_assoc(:replacement_services, with: &ReplacementService.changeset/2)
    |> validate_required([:title, :mode, :is_active])
    |> validate_required_for(:is_active)
  end

  def new(attrs \\ %{}) do
    %__MODULE__{limits: [], replacement_services: [], mode: :subway}
    |> struct!(attrs)
  end

  @doc """
  Returns true if `disruption_v2` has any manually-entered or derived limits.
  """
  @spec has_limits?(t()) :: boolean
  def has_limits?(%__MODULE__{} = disruption_v2) do
    disruption_v2 = Repo.preload(disruption_v2, [:limits, :hastus_exports])

    not Enum.empty?(disruption_v2.limits) or
      Enum.any?(disruption_v2.hastus_exports, &Export.has_derived_limits?/1)
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

  defp validate_required_for(changeset, :is_active) do
    id = get_field(changeset, :id)

    if id != nil and get_field(changeset, :is_active) do
      non_active_activated_shuttles =
        Repo.all(
          from d in __MODULE__,
            join: s in assoc(d, :shuttles),
            where: d.id == ^id,
            where: s.status != :active,
            distinct: s.id,
            select: s
        )

      if non_active_activated_shuttles == [] do
        changeset
      else
        shuttles = Enum.map_join(non_active_activated_shuttles, ", ", & &1.shuttle_name)

        add_error(
          changeset,
          :is_active,
          "the following shuttle(s) used by this disruption must be set as 'active' first: #{shuttles}"
        )
      end
    else
      changeset
    end
  end
end
