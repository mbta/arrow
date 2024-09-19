defmodule Arrow.Gtfs.Types.Time do
  @moduledoc """
  Custom Ecto type to handle timestamps as they appear in the GTFS feed.

  e.g. "08:15:00", "24:08:00"

  Data is encoded as a map so we can indicate when a time is after midnight.

  For example, "24:08:00" would be encoded as

      %{time: ~T[00:08:00], after_midnight?: true}
  """

  use Ecto.Type

  @type t :: %{
          time: Time.t(),
          after_midnight?: boolean
        }

  defguardp is_t(value) when is_struct(value.time, Time) and is_boolean(value.after_midnight?)

  def type, do: :map

  def cast(<<hour::binary-size(2), ?:, minute::binary-size(2), ?:, second::binary-size(2)>>) do
    with {hour, ""} <- Integer.parse(hour),
         {minute, ""} <- Integer.parse(minute),
         {second, ""} <- Integer.parse(second) do
      after_midnight? = hour >= 24
      hour = if after_midnight?, do: hour - 24, else: hour

      case Time.new(hour, minute, second) do
        {:ok, t} -> {:ok, %{time: t, after_midnight?: after_midnight?}}
        error -> error
      end
    else
      _ -> :error
    end
  end

  def cast(_), do: :error

  def load(%{"after_midnight?" => after_midnight?, "time" => time})
      when is_boolean(after_midnight?) and is_binary(time) do
    case Time.from_iso8601(time) do
      {:ok, t} -> {:ok, %{after_midnight?: after_midnight?, time: t}}
      {:error, _} -> :error
    end
  end

  def load(_), do: :error

  def dump(data) when is_t(data) do
    {:ok, data}
  end

  def dump(_), do: :error

  def equal?(t1, t2) when is_t(t1) and is_t(t2) do
    t1.after_midnight? and t2.after_midnight? and Time.compare(t1.time, t2.time) == :eq
  end

  def equal?(_, _), do: false
end
