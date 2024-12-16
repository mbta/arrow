defmodule Arrow.OpenRouteServiceAPI.DirectionsResponse do
  @moduledoc """
  A structured response from the OpenRouteService Directions API
  """
  @derive Jason.Encoder

  @typedoc """
    Type that represents a response from OpenRouteService's Directions API
  """
  @type t() :: %__MODULE__{
          coordinates: [[float()]],
          segments: [
            %{
              duration: float(),
              distance: float()
            }
          ],
          summary: %{
            duration: float(),
            distance: float()
          }
        }

  defstruct coordinates: [], segments: [], summary: %{}
end
