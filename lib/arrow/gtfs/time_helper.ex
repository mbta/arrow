defmodule Arrow.Gtfs.TimeHelper do
  @moduledoc """
  Utility functions for converting GTFS timestamps, which can go past midnight,
  to other representations.
  """

  @type timestamp :: String.t()

  @minute_in_seconds 60
  @hour_in_seconds 60 * @minute_in_seconds

  @doc """
  Converts a GTFS timestamp to number of seconds after midnight on the start of the service day.

  Examples:

      iex> to_seconds_after_midnight!("08:47:30")
      31_650

      iex> to_seconds_after_midnight!("24:15:00")
      87_300
  """
  @spec to_seconds_after_midnight!(timestamp) :: non_neg_integer
  def to_seconds_after_midnight!(timestamp) do
    {h, m, s} = parse_parts(timestamp)

    h * @hour_in_seconds + m * @minute_in_seconds + s
  end

  @doc """
  Converts a GTFS timestamp to a map containing a Time struct and a boolean field indicating if
  that time is after midnight, i.e., close to the end of the service day.

  Examples:

      iex> to_annotated_time!("08:47:30")
      %{time: ~T[08:47:30], after_midnight?: false}

      iex> to_annotated_time!("24:15:00")
      %{time: ~T[00:15:00], after_midnight?: true}
  """
  @spec to_annotated_time!(timestamp) :: %{time: Time.t(), after_midnight?: boolean}
  def to_annotated_time!(timestamp) do
    {h, m, s} = parse_parts(timestamp)
    after_midnight? = h >= 24
    h = if after_midnight?, do: h - 24, else: h

    %{time: Time.new!(h, m, s), after_midnight?: after_midnight?}
  end

  defp parse_parts(<<h::binary-size(2), ?:, m::binary-size(2), ?:, s::binary-size(2)>>) do
    {h, ""} = Integer.parse(h)
    {m, ""} = Integer.parse(m)
    {s, ""} = Integer.parse(s)

    {h, m, s}
  end
end
