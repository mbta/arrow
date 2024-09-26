defmodule Arrow.Gtfs.Types.Time do
  @moduledoc """
  Custom Ecto type to handle timestamps as they appear in the GTFS feed.

  e.g. "08:15:00", "24:08:00"

  Data is loaded as a map so we can indicate when a time is after midnight.

  For example, "24:08:00" would be loaded as

      %{
        time: ~T[00:08:00],
        after_midnight?: true,
        seconds: 86_880,
        source: "24:08:00"
      }

  Data is dumped to the DB as a timestamp string.
  """

  use Ecto.Type

  @type t :: %{
          time: Time.t(),
          after_midnight?: boolean,
          # Time in seconds since 00:00:00
          seconds: integer,
          source: String.t()
        }

  defguardp is_t(value)
            when is_struct(value.time, Time) and is_boolean(value.after_midnight?) and
                   is_binary(value.source)

  def type, do: :string

  def cast(timestamp), do: from_timestamp(timestamp)
  def load(timestamp), do: from_timestamp(timestamp)
  def dump(map), do: to_timestamp(map)

  defp to_timestamp(t) when is_t(t), do: {:ok, t.source}
  defp to_timestamp(_), do: :error

  @minute 60
  @hour 60 * @minute
  @day 24 * @hour

  defp from_timestamp(
         <<h::binary-size(2), ?:, m::binary-size(2), ?:, s::binary-size(2)>> = timestamp
       ) do
    with {h, ""} <- Integer.parse(h),
         {m, ""} <- Integer.parse(m),
         {s, ""} <- Integer.parse(s),
         after_midnight? = h >= 24,
         h = if(after_midnight?, do: h - 24, else: h),
         {:ok, time} <- Time.new(h, m, s) do
      {seconds, _usec} = Time.to_seconds_after_midnight(time)
      seconds = if after_midnight?, do: seconds + @day, else: seconds
      t = %{time: time, after_midnight?: after_midnight?, seconds: seconds, source: timestamp}

      {:ok, t}
    else
      _ -> :error
    end
  end

  def equal?(t1, t2) when is_t(t1) and is_t(t2), do: t1.source == t2.source
  def equal?(_, _), do: false
end
