defmodule Arrow.OpenRouteServiceAPI.DirectionsRequest do
  @moduledoc """
  A request to the OpenRouteService Directions API
  """
  @derive Jason.Encoder

  defmodule Options do
    @moduledoc false
    defmodule ProfileParams do
      @moduledoc false
      defmodule HgvRestrictions do
        @derive Jason.Encoder
        @moduledoc false
        @type t :: %__MODULE__{length: float(), width: float(), height: float()}
        defstruct [:length, :width, :height]

        def bus_40ft,
          do: %HgvRestrictions{
            length: 12.192,
            width: 3.2004,
            height: 3.5052
          }
      end

      @type t :: %{restrictions: HgvRestrictions.t()}
    end

    @type t :: %{profile_params: ProfileParams.t(), vehicle_type: String.t()}
  end

  @typedoc """
    Type that represents a request made to OpenRouteService's Directions API
  """
  @type t() :: %__MODULE__{
          coordinates: [[float()]],
          continue_straight: boolean(),
          options: Options.t()
        }

  defstruct coordinates: [],
            continue_straight: true,
            options: %{
              vehicle_type: "bus",
              profile_params: %{
                restrictions:
                  Arrow.OpenRouteServiceAPI.DirectionsRequest.Options.ProfileParams.HgvRestrictions.bus_40ft()
              }
            }
end
