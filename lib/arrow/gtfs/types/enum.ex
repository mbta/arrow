# credo:disable-for-this-file
defmodule Arrow.Gtfs.Types.Enum do
  @moduledoc """
  Ecto.Enum, except it accepts string-formatted integers when casting to an
  integer-valued enum.

  Code is copied directly from Ecto.Enum @3.11.0, with the only
  change being the expression bound to `on_cast`.
  """

  use Ecto.ParameterizedType

  @impl true
  def type(params), do: params.type

  @impl true
  def init(opts) do
    values = opts[:values]

    {type, mappings} =
      cond do
        is_list(values) and Enum.all?(values, &is_atom/1) ->
          validate_unique!(values)
          {:string, Enum.map(values, fn atom -> {atom, to_string(atom)} end)}

        type = Keyword.keyword?(values) and infer_type(Keyword.values(values)) ->
          validate_unique!(Keyword.keys(values))
          validate_unique!(Keyword.values(values))
          {type, values}

        true ->
          raise ArgumentError, """
          Ecto.Enum types must have a values option specified as a list of atoms or a
          keyword list with a mapping from atoms to either integer or string values.

          For example:

              field :my_field, Ecto.Enum, values: [:foo, :bar]

          or

              field :my_field, Ecto.Enum, values: [foo: 1, bar: 2, baz: 5]
          """
      end

    on_load = Map.new(mappings, fn {key, val} -> {val, key} end)
    on_dump = Map.new(mappings)

    # This is the only thing that's different from Ecto.Enum.
    on_cast =
      case type do
        :integer ->
          mappings
          |> Enum.flat_map(fn {key, val} ->
            [{Atom.to_string(key), key}, {Integer.to_string(val), key}]
          end)
          |> Map.new()

        _ ->
          Map.new(mappings, fn {key, _} -> {Atom.to_string(key), key} end)
      end

    embed_as =
      case Keyword.get(opts, :embed_as, :values) do
        :values ->
          :self

        :dumped ->
          :dump

        other ->
          raise ArgumentError, """
          the `:embed_as` option for `Ecto.Enum` accepts either `:values` or `:dumped`,
          received: `#{inspect(other)}`
          """
      end

    %{
      on_load: on_load,
      on_dump: on_dump,
      on_cast: on_cast,
      mappings: mappings,
      embed_as: embed_as,
      type: type
    }
  end

  defp validate_unique!(values) do
    if length(Enum.uniq(values)) != length(values) do
      raise ArgumentError, """
      Ecto.Enum type values must be unique.

      For example:

          field :my_field, Ecto.Enum, values: [:foo, :bar, :foo]

      is invalid, while

          field :my_field, Ecto.Enum, values: [:foo, :bar, :baz]

      is valid
      """
    end
  end

  defp infer_type(values) do
    cond do
      Enum.all?(values, &is_integer/1) -> :integer
      Enum.all?(values, &is_binary/1) -> :string
      true -> nil
    end
  end

  @impl true
  def cast(nil, _params), do: {:ok, nil}

  def cast(data, params) do
    case params do
      %{on_load: %{^data => as_atom}} -> {:ok, as_atom}
      %{on_dump: %{^data => _}} -> {:ok, data}
      %{on_cast: %{^data => as_atom}} -> {:ok, as_atom}
      _ -> :error
    end
  end

  @impl true
  def load(nil, _, _), do: {:ok, nil}

  def load(data, _loader, %{on_load: on_load}) do
    case on_load do
      %{^data => as_atom} -> {:ok, as_atom}
      _ -> :error
    end
  end

  @impl true
  def dump(nil, _, _), do: {:ok, nil}

  def dump(data, _dumper, %{on_dump: on_dump}) do
    case on_dump do
      %{^data => as_string} -> {:ok, as_string}
      _ -> :error
    end
  end

  @impl true
  def equal?(a, b, _params), do: a == b

  @impl true
  def embed_as(_, %{embed_as: embed_as}), do: embed_as

  @impl true
  def format(%{mappings: mappings}) do
    "#Ecto.Enum<values: #{inspect(Keyword.keys(mappings))}>"
  end

  @doc "Returns the possible values for a given schema or types map and field"
  @spec values(map | module, atom) :: [atom()]
  def values(schema_or_types, field) do
    schema_or_types
    |> mappings(field)
    |> Keyword.keys()
  end

  @doc "Returns the possible dump values for a given schema or types map and field"
  @spec dump_values(map | module, atom) :: [String.t()] | [integer()]
  def dump_values(schema_or_types, field) do
    schema_or_types
    |> mappings(field)
    |> Keyword.values()
  end

  @doc "Returns the mappings between values and dumped values"
  @spec mappings(map, atom) :: Keyword.t()
  def mappings(types, field) when is_map(types) do
    case types do
      %{^field => {:parameterized, Ecto.Enum, %{mappings: mappings}}} -> mappings
      %{^field => {_, {:parameterized, Ecto.Enum, %{mappings: mappings}}}} -> mappings
      %{^field => _} -> raise ArgumentError, "#{field} is not an Ecto.Enum field"
      %{} -> raise ArgumentError, "#{field} does not exist"
    end
  end

  @spec mappings(module, atom) :: Keyword.t()
  def mappings(schema, field) do
    try do
      schema.__changeset__()
    rescue
      _ in UndefinedFunctionError ->
        raise ArgumentError, "#{inspect(schema)} is not an Ecto schema or types map"
    else
      %{} = types -> mappings(types, field)
    end
  end
end
