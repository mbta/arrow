defmodule Arrow.Repo.Migrations.DropShuttlesInvalidDirectionDescriptions do
  use Ecto.Migration

  defp get_valid_direction_sql_strings do
    Enum.map_join(Arrow.Shuttles.Route.direction_desc_values(), ",", &"'#{&1}'")
  end

  def up do
    execute(
      """
        DELETE FROM shuttle_route_stops 
        WHERE shuttle_route_id IN 
          (SELECT shuttle_route_id FROM shuttle_routes WHERE direction_desc NOT IN (#{get_valid_direction_sql_strings()}));
      """,
      "SELECT 0"
    )

    execute(
      """
        DELETE FROM shuttle_routes 
        WHERE direction_desc NOT IN (#{get_valid_direction_sql_strings()});
      """,
      "SELECT 0"
    )
  end
end
