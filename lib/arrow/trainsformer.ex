defmodule Arrow.Trainsformer do
  @moduledoc """
  The Trainsformer context.
  """

  import Ecto.Query, warn: false
  alias Arrow.Repo

  alias Arrow.Trainsformer.Export

  @preloads [
    :disruption
  ]

  @doc """
  Returns the list of trainsformer_exports.

  ## Examples

      iex> list_trainsformer_exports()
      [%Export{}, ...]

  """
  def list_trainsformer_exports do
    Export |> Repo.all() |> Repo.preload(@preloads)
  end

  @doc """
  Gets a single export.

  Raises if the Export does not exist.

  ## Examples

      iex> get_export!(123)
      %Export{}

  """
  def get_export!(id), do: Export |> Repo.get!(id) |> Repo.preload(@preloads)

  @doc """
  Creates a export.

  ## Examples

      iex> create_export(%{field: value})
      {:ok, %Export{}}

      iex> create_export(%{field: bad_value})
      {:error, ...}

  """
  def create_export(attrs \\ %{}) do
    %Export{}
    |> Export.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a export.

  ## Examples

      iex> update_export(export, %{field: new_value})
      {:ok, %Export{}}

      iex> update_export(export, %{field: bad_value})
      {:error, ...}

  """
  def update_export(%Export{} = export, attrs) do
    export
    |> Export.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Export.

  ## Examples

      iex> delete_export(export)
      {:ok, %Export{}}

      iex> delete_export(export)
      {:error, ...}

  """
  def delete_export(%Export{} = export) do
    Repo.delete(export)
  end

  @doc """
  Returns a data structure for tracking export changes.

  ## Examples

      iex> change_export(export)
      %Todo{...}

  """
  def change_export(%Export{} = export, attrs \\ %{}) do
    Export.changeset(export, attrs)
  end
end
