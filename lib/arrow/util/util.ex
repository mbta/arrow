defmodule Arrow.Util do
  @moduledoc false

  @spec sanitized_string_for_sql_like(String.t()) :: String.t()
  def sanitized_string_for_sql_like(string) do
    # See https://github.blog/engineering/like-injection/
    Regex.replace(~r/([\%_])/, string, fn _, x -> "\\#{x}" end) <> "%"
  end

  @spec read_zip(Path.t(), list(charlist()), Path.t()) ::
          {:ok, binary(), map()} | {:error, term()}
  def read_zip(zip_path, required_files, tmp_dir) do
    with {:ok, zip_bin} <- File.read(zip_path),
         {:ok, unzipped_file_list} <-
           :zip.unzip(zip_bin, file_list: required_files, cwd: tmp_dir),
         {:ok, file_map} <- read_csvs(unzipped_file_list, required_files, tmp_dir) do
      {:ok, zip_bin, file_map}
    end
  end

  defp read_csvs(unzipped_files, required_files, tmp_dir) do
    missing_files =
      Enum.filter(required_files, &(get_unzipped_file_path(&1, tmp_dir) not in unzipped_files))

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

  @adjustment_kind_icon_names %{
    blue_line: "blue-line",
    bus: "mode-bus",
    commuter_rail: "mode-commuter-rail",
    green_line: "green-line",
    green_line_b: "green-line-b",
    green_line_c: "green-line-c",
    green_line_d: "green-line-d",
    green_line_e: "green-line-e",
    mattapan_line: "mattapan-line",
    orange_line: "orange-line",
    red_line: "red-line",
    silver_line: "silver-line"
  }

  defp adjustment_kind_icon_path(conn_or_socket, kind) do
    Phoenix.VerifiedRoutes.static_path(
      conn_or_socket,
      "/images/icon-#{@adjustment_kind_icon_names[kind]}-small.svg"
    )
  end

  def icon_paths(conn_or_socket) do
    @adjustment_kind_icon_names
    |> Map.new(fn {kind, _icon_name} ->
      {kind, adjustment_kind_icon_path(conn_or_socket, kind)}
    end)
    |> Map.put(
      :subway,
      Phoenix.VerifiedRoutes.static_path(conn_or_socket, "/images/icon-mode-subway-small.svg")
    )
    |> Map.put(
      :bus_outline,
      Phoenix.VerifiedRoutes.static_path(conn_or_socket, "/images/icon-bus-outline-small.svg")
    )
  end

  @spec validate_start_date_before_end_date(Ecto.Changeset.t(any())) :: Ecto.Changeset.t(any())
  def validate_start_date_before_end_date(changeset) do
    start_date = Ecto.Changeset.get_field(changeset, :start_date)
    end_date = Ecto.Changeset.get_field(changeset, :end_date)

    cond do
      is_nil(start_date) or is_nil(end_date) ->
        changeset

      Date.compare(start_date, end_date) == :gt ->
        Ecto.Changeset.add_error(
          changeset,
          :start_date,
          "start date must be less than or equal to end date"
        )

      true ->
        changeset
    end
  end
end
