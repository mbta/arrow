defmodule Arrow.Repo.MapForForm do
  use Ecto.Type

  def type, do: :map

  # External Data
  def cast(map) when is_binary(map) do
    {:ok, decode_map(map)}
  end

  def cast(map) when is_map(map) do
    {:ok, map}
  end

  def cast(_), do: :error

  # Internal Data
  def load(map) when is_map(map) do
    {:ok, map}
  end

  def load(_), do: :error

  # To database
  def dump(map) when is_map(map) do
    {:ok, map}
  end

  def dump(_), do: :error

  defp decode_map(map) when is_binary(map) do
    case Jason.decode(map) do
      {:ok, data} -> data
      error -> error
    end
  end
end
