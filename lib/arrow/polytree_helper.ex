defmodule Arrow.PolytreeHelper do
  @moduledoc """
  Functions for creating and analyzing UnrootedPolytree structures.

  Intended for use with subway line stop sequences, but can work with any UnrootedPolytree.
  """
  alias UnrootedPolytree, as: UPTree

  @doc """
  Returns a list of IDs for all nodes in the polytree that have no previous nodes.
  """
  @spec leftmost_ids(UPTree.t()) :: [UPTree.Node.id()]
  def leftmost_ids(%UPTree{} = tree), do: do_leftmost(tree, tree.starting_nodes)

  @doc """
  Returns a list of all possible paths from a leftmost node to a rightmost node
  in the polytree.

  Each path is a list of node IDs, where the first element is a leftmost node
  and the last is a rightmost node.
  """
  @spec all_full_paths(UPTree.t()) :: [[UPTree.Node.id()]]
  def all_full_paths(%UPTree{} = tree) do
    tree
    |> leftmost_ids()
    |> Enum.map(&[&1])
    |> then(&build_paths(tree, &1))
  end

  @doc """
  Constructs an UnrootedPolytree from a list of stop sequences.
  """
  @spec seqs_to_tree([[stop_id :: String.t()]]) :: UPTree.t()
  def seqs_to_tree(seqs) do
    seqs
    |> Enum.map(fn seq -> Enum.map(seq, &{&1, &1}) end)
    |> UPTree.from_lists()
  end

  defp do_leftmost(tree, ids, acc \\ [], visited \\ MapSet.new())

  defp do_leftmost(_tree, [], acc, _visited), do: Enum.uniq(acc)

  defp do_leftmost(tree, ids, acc, visited) do
    {prev_ids, acc} =
      Enum.reduce(ids, {[], acc}, fn id, {prev_ids, acc} ->
        case UPTree.edges_for_id(tree, id).previous do
          [] -> {prev_ids, [id | acc]}
          prev -> {Enum.reject(prev, &(&1 in visited)) ++ prev_ids, acc}
        end
      end)

    do_leftmost(tree, prev_ids, acc, for(id <- ids, into: visited, do: id))
  end

  defp build_paths(tree, paths) do
    if Enum.all?(paths, &match?({:done, _}, &1)) do
      Enum.map(paths, fn {:done, path} -> Enum.reverse(path) end)
    else
      paths
      |> Enum.flat_map(fn
        {:done, path} ->
          [{:done, path}]

        [id | _] = path ->
          case UPTree.edges_for_id(tree, id).next do
            [] -> [{:done, path}]
            next -> Enum.map(next, &[&1 | path])
          end
      end)
      |> then(&build_paths(tree, &1))
    end
  end
end
