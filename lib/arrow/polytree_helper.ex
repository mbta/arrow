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

  defp build_paths(tree, paths, completed \\ [])

  defp build_paths(_tree, [], completed) do
    completed
    |> Enum.reverse()
    |> Enum.map(&Enum.reverse/1)
  end

  defp build_paths(tree, paths, completed) do
    paths_with_next =
      Enum.map(paths, fn [id | _] = path -> {path, UPTree.edges_for_id(tree, id).next} end)

    {new_completed, paths} =
      Enum.split_with(paths_with_next, &match?({_path, []}, &1))

    new_completed = Enum.map(new_completed, fn {path, _} -> path end)
    new_paths = Enum.flat_map(paths, fn {path, next} -> Enum.map(next, &[&1 | path]) end)

    build_paths(tree, new_paths, Enum.reverse(new_completed) ++ completed)
  end
end
