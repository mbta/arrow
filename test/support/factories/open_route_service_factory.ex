defmodule Arrow.OpenRouteServiceFactory do
  @moduledoc """
  Defines ExMachina factory functions for `Arrow.Factory` related to
  open route service API return values
  """

  defmacro __using__(_opts) do
    quote do
      def ors_directions_summary_json_factory do
        %{
          "distance" => sequence("ors_summary_distance"),
          "duration" => sequence("ors_summary_duration")
        }
      end

      def ors_directions_distance_factory do
        %{
          "distance" => sequence("ors_segment_distance"),
          "duration" => sequence("ors_segment_duration")
        }
      end

      def ors_directions_segment_json_factory do
        %{
          "steps" =>
            build_list(
              sequence("ors_segment_json_num_steps", [4, 1, 3, 2]),
              :ors_directions_distance_json
            )
        }
      end

      def ors_directions_json_factory(attrs) do
        coordinates = Map.get(attrs, :coordinates, [[0, 0], [1, 1], [2, 2]])

        segments =
          Map.get_lazy(attrs, :segments, fn ->
            build_list(3, :ors_directions_segment_json)
          end)

        summary =
          Map.get_lazy(attrs, :summary, fn ->
            build(
              :ors_directions_summary_json,
              Enum.reduce(
                segments,
                &%{
                  "distance" => &1["distance"] + &2["distance"],
                  "duration" => &1["duration"] + &2["duration"]
                }
              )
            )
          end)

        %{
          "features" => [
            %{
              "geometry" => %{"coordinates" => coordinates},
              "properties" => %{
                "segments" => segments,
                "summary" => summary
              }
            }
          ]
        }
      end
    end
  end
end
