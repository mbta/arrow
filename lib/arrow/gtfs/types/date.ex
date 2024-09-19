defmodule Arrow.Gtfs.Types.Date do
  @moduledoc """
  Custom Ecto type to handle datestamps as they appear in the GTFS feed.

  e.g. "20240901"
  """

  use Ecto.Type
  def type, do: :date

  def cast(<<year::binary-size(4), month::binary-size(2), day::binary-size(2)>>) do
    with {year, ""} <- Integer.parse(year),
         {month, ""} <- Integer.parse(month),
         {day, ""} <- Integer.parse(day) do
      Date.new(year, month, day)
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  def load(%Date{} = date), do: {:ok, date}
  def load(_), do: :error

  def dump(%Date{} = date), do: {:ok, date}
  def dump(_), do: :error

  def equal?(%Date{} = d1, %Date{} = d2) do
    Date.compare(d1, d2) == :eq
  end

  def equal?(_, _), do: false
end
