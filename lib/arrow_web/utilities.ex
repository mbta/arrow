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
end
