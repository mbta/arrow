defmodule ArrowWeb.DisruptionV2Controller.Filters.Calendar do
  @moduledoc "Handles filters unique to the calendar view (currently none)."

  @behaviour ArrowWeb.DisruptionController.Filters.Behaviour

  @type t :: %__MODULE__{}

  defstruct []

  def from_params(_), do: %__MODULE__{}
  def resettable?(_), do: false
  def reset(calendar), do: calendar
  def to_params(_), do: %{}
end
