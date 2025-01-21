defmodule Arrow.Repo.Migrations.DropShuttlesInvalidDirectionDescriptions do
  use Ecto.Migration

  defp get_valid_direction_sql_strings() do
    Arrow.Shuttles.Route.direction_desc_values() |> Enum.map(&"'#{&1}'") |> Enum.join(",")
  end

  def change do
    execute("""
      DELETE FROM shuttle_route_stops 
      WHERE shuttle_route_id IN 
        (SELECT shuttle_route_id FROM shuttle_routes WHERE direction_desc NOT IN (#{get_valid_direction_sql_strings()}));
    """)

    execute("""
      DELETE FROM shuttle_routes 
      WHERE direction_desc NOT IN (#{get_valid_direction_sql_strings()});
    """)
  end
end
