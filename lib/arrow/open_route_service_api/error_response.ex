defmodule Arrow.OpenRouteServiceAPI.ErrorResponse do
  @moduledoc """
  A structured error from the OpenRouteService API
  """
  @derive Jason.Encoder

  @typedoc """
    Type that represents an error from OpenRouteService's API
  """
  @type t() :: %__MODULE__{
          type: :no_route | :unknown
        }

  defstruct type: :unknown
end
