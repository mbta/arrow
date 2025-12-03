defmodule Arrow.Trainsformer.ExportUpload do
  @moduledoc """
  Functions for validating, parsing, and saving Trainsformer export uploads.
  """

  @type t :: %__MODULE__{
          zip_binary: binary()
        }

  @enforce_keys [:zip_binary]
  defstruct @enforce_keys

  @filenames [
    ~c"multi_route_trips.txt",
    ~c"stop_times.txt",
    ~c"transfers.txt",
    ~c"trips.txt"
  ]

  @doc """
  Parses a Trainsformer export and returns a list of data
  Includes a rescue clause to catch errors while parsing user-provided data
  """
  @spec extract_data_from_upload(%{:path => binary()}, String.t()) ::
          {:ok, {:ok, t()} | {:error, String.t()}}
  def extract_data_from_upload(%{path: zip_path}, user_id) do
    tmp_dir = ~c"tmp/trainsformer/#{user_id}"

    with {:ok, zip_bin} <- File.read(zip_path),
         {:ok, _unzipped_file_list} <- :zip.unzip(zip_bin, file_list: @filenames, cwd: tmp_dir) do
      _ = File.rm_rf!(tmp_dir)

      export_data = %__MODULE__{
        zip_binary: zip_bin
      }

      {:ok, {:ok, export_data}}
    else
      {:error, error} ->
        _ = File.rm_rf!(tmp_dir)
        {:ok, {:error, error}}
    end
  end
end
