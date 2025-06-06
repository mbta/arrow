defmodule ArrowWeb.DisruptionV2Controller.Filters.Behaviour do
  @moduledoc "Required behaviour for `Filters` sub-modules."
  @callback from_params(Plug.Conn.params()) :: struct
  @callback resettable?(struct) :: boolean
  @callback reset(struct) :: struct
  @callback to_params(struct) :: Plug.Conn.params()
end
