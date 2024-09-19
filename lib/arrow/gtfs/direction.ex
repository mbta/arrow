defmodule Arrow.Gtfs.Direction do
  use Arrow.Gtfs.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          route: Arrow.Gtfs.Route.t() | Ecto.Association.NotLoaded.t(),
          direction_id: 0 | 1,
          desc: String.t(),
          destination: String.t()
        }

  @primary_key false

  schema "gtfs_directions" do
    belongs_to :route, Arrow.Gtfs.Route, primary_key: true
    field :direction_id, :integer, primary_key: true
    field :desc, :string
    field :destination, :string
  end

  #############################################################################
  # TODO: Several rows in directions.txt reference nonexistent routes,      #
  #       causing import to fail. What do?                                  #
  #                                                                         #
  #       RBQL for all offending rows: (query starting from directions.txt) #
  #       SELECT * LEFT JOIN routes.txt                                     #
  #          ON a.route_id = b.route_id                                     #
  #          WHERE b.route_id == null                                       #
  #############################################################################
  @bad_route_ids ~w[602 Shuttle-AshlandSouthStation Shuttle-AshlandSouthStation Shuttle-BackBayFraminghamExpress Shuttle-BackBayFraminghamExpress Shuttle-BackBayFraminghamLocal Shuttle-BackBayFraminghamLocal Shuttle-BackBayNorthStation Shuttle-BackBayNorthStation Shuttle-BackBaySullivan Shuttle-BackBaySullivan Shuttle-BackBayWellesleyHillsLocal Shuttle-BackBayWellesleyHillsLocal Shuttle-BeverlyNorthStationExpress Shuttle-BeverlyNorthStationExpress Shuttle-BeverlyNorthStationLocal Shuttle-BeverlyNorthStationLocal Shuttle-BeverlyOrientHeightsExpress Shuttle-BeverlyOrientHeightsExpress Shuttle-BeverlyOrientHeightsLimited Shuttle-BeverlyOrientHeightsLimited Shuttle-BeverlyOrientHeightsLocal Shuttle-BeverlyOrientHeightsLocal Shuttle-BeverlyWellingtonExpress Shuttle-BeverlyWellingtonExpress Shuttle-BeverlyWellingtonLocal Shuttle-BeverlyWellingtonLocal Shuttle-BrooklineHillsCopley Shuttle-BrooklineHillsCopley Shuttle-ClevelandCircleCopley Shuttle-ClevelandCircleCopley Shuttle-CopleyForestHills Shuttle-CopleyForestHills Shuttle-EastFirstSouthStation Shuttle-EastFirstSouthStation Shuttle-FraminghamRiverside Shuttle-FraminghamRiverside Shuttle-FraminghamWorcester Shuttle-FraminghamWorcester Shuttle-GovernmentCenterLechmere Shuttle-GovernmentCenterLechmere Shuttle-GovernmentCenterOakGrove Shuttle-GovernmentCenterOakGrove Shuttle-GovernmentCenterTuftsMedical Shuttle-GovernmentCenterTuftsMedical Shuttle-GreenbushSouthStation Shuttle-GreenbushSouthStation Shuttle-HaymarketSullivan Shuttle-HaymarketSullivan Shuttle-JFKMattapan Shuttle-JFKMattapan Shuttle-LowellNorthStationExpress Shuttle-LowellNorthStationExpress Shuttle-LowellWellington Shuttle-LowellWellington Shuttle-NewburyportNorthStationLimited Shuttle-NewburyportNorthStationLimited Shuttle-NewtonHighlandsWellesleyFarms Shuttle-NewtonHighlandsWellesleyFarms Shuttle-NorthQuincyQuincyCenter Shuttle-NorthQuincyQuincyCenter Shuttle-NorthStationMaldenOakGrove Shuttle-NorthStationMaldenOakGrove Shuttle-NorthStationReading Shuttle-NorthStationReading Shuttle-NorthStationSwampscottExpress Shuttle-NorthStationSwampscottExpress Shuttle-NorthStationSwampscottLocal Shuttle-NorthStationSwampscottLocal Shuttle-NorthStationWilmington Shuttle-NorthStationWilmington Shuttle-OrientHeightsRockportExpress Shuttle-OrientHeightsRockportExpress Shuttle-OrientHeightsRockportLimited Shuttle-OrientHeightsRockportLimited Shuttle-OrientHeightsRockportLocal Shuttle-OrientHeightsRockportLocal Shuttle-RockportNorthStationLimited Shuttle-RockportNorthStationLimited Shuttle-RugglesSullivan Shuttle-RugglesSullivan]

  def changeset(direction, %{"route_id" => id} = attrs) when id in @bad_route_ids do
    direction
    |> cast(attrs, ~w[route_id direction_id desc destination]a)
    |> Map.replace!(:action, :ignore_bad_row)
  end

  def changeset(direction, attrs) do
    attrs =
      attrs
      # Taking liberties:
      # `direction` is inconsistently named--the human-readable name is
      # "#{table}_desc" in all other tables.
      |> Map.pop("direction")
      |> then(fn
        {nil, attrs} -> attrs
        {desc, attrs} -> Map.put(attrs, "desc", desc)
      end)
      |> remove_table_prefix("direction", except: ["direction_id"])

    direction
    |> cast(attrs, ~w[route_id direction_id desc destination]a)
    |> validate_required(~w[route_id direction_id desc destination]a)
    |> validate_inclusion(:direction_id, 0..1)
    |> assoc_constraint(:route)
  end
end
