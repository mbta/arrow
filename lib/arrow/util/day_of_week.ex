defmodule Arrow.Util.DayOfWeek do
  @moduledoc """
    Utilities for working with numeric days of the week 
  """

  @type day_name :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday

  @day_name_atoms ~w[monday tuesday wednesday thursday friday saturday sunday]a

  @day_name_values Enum.with_index(
                     @day_name_atoms,
                     1
                   )

  @spec get_day_name(1..7) :: day_name
  for {name, number} <- @day_name_values do
    def get_day_name(unquote(number)), do: unquote(name)
  end

  @spec get_all_day_names() :: [day_name]
  def get_all_day_names, do: @day_name_atoms

  @spec day_name_values() :: [{day_name, 1..7}]
  def day_name_values, do: @day_name_values
end
