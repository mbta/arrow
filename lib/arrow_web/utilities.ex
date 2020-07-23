defmodule ArrowWeb.Utilities do
  @doc """
  Extract the info from a json:api formatted set of relationships.

  Takes data in the form of

  %{
    "rel1" => %{
      "data" => [
        %{ ...json api resource...},
        %{ ...json api resource...}
      ]
    },
    "rel2" => %{
      "data" => %{ ...json api resource...}
    }
  }

  and returns

  %{
    "rel1" => [
      ...JaSerializer.Params.to_attributes/1'ed form of resource,
      ...JaSerializer.Params.to_attributes/1'ed form of resource,
    ],
    "rel2" => ...JaSerializer.Params.to_attributes/1'ed form of resource,
  }

  Note that it handles resources in a list, and singular resources.
  """
  @spec get_json_api_relationships(map()) :: map()
  def get_json_api_relationships(params_relationships) do
    Enum.reduce(
      params_relationships,
      %{},
      fn {relationship, %{"data" => data}}, rels ->
        if is_list(data) do
          Map.put(rels, relationship, Enum.map(data, &JaSerializer.Params.to_attributes/1))
        else
          Map.put(rels, relationship, JaSerializer.Params.to_attributes(data))
        end
      end
    )
  end

  @spec format_field_name(atom()) :: String.t()
  defp format_field_name(field) do
    Atom.to_string(field) |> String.replace("_", " ") |> String.capitalize()
  end

  @spec format_error_message({String.t(), [any()]}) :: String.t()
  defp format_error_message({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value))
    end)
  end

  @spec take_errors(map()) :: [key: String.t()]
  defp take_errors(errors) do
    Enum.flat_map(errors, fn {field, [err | _] = field_errors} ->
      if is_binary(err) do
        [{field, err}]
      else
        Enum.flat_map(field_errors, fn x -> take_errors(x) end)
      end
    end)
  end

  @spec format_errors(Ecto.Changeset.t()) :: [map()]
  def format_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn err ->
      format_error_message(err)
    end)
    |> take_errors()
    |> Enum.map(fn {field, msg} ->
      %{detail: "#{format_field_name(field)} #{msg}"}
    end)
  end
end
