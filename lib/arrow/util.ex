defmodule Arrow.Util do
  @moduledoc false

  @spec sanitized_string_for_sql_like(String.t()) :: String.t()
  def sanitized_string_for_sql_like(string) do
    # See https://github.blog/engineering/like-injection/
    Regex.replace(~r/([\%_])/, string, fn _, x -> "\\#{x}" end) <> "%"
  end

  @spec read_zip(Path.t(), list(charlist()), Path.t()) :: {:ok, binary(), map()} | {:error, term()}
  def read_zip(zip_path, required_files, tmp_dir) do
    with {:ok, zip_bin} <- File.read(zip_path),
         {:ok, unzipped_file_list} <- :zip.unzip(zip_bin, file_list: required_files, cwd: tmp_dir),
         {:ok, file_map} <- read_csvs(unzipped_file_list, required_files, tmp_dir) do
      {:ok, zip_bin, file_map}
    end
  end

  defp read_csvs(unzipped_files, required_files, tmp_dir) do
    missing_files = Enum.filter(required_files, &(get_unzipped_file_path(&1, tmp_dir) not in unzipped_files))

    if Enum.any?(missing_files) do
      {:error,
       "The following files are missing from the export: #{Enum.join(missing_files, ", ")}"}
    else
      map =
        required_files
        |> Enum.map(fn filename ->
          data =
            filename
            |> get_unzipped_file_path(tmp_dir)
            |> File.stream!()
            |> CSV.decode!(headers: true)

          {to_string(filename), data}
        end)
        |> Map.new()

      {:ok, map}
    end
  end

  defp get_unzipped_file_path(filename, tmp_dir), do: ~c"#{tmp_dir}/#{filename}"
end
