defmodule Arrow.Shuttles.ActivationUpload do
  @moduledoc "functions for extracting shuttle activations from xlsx uploads"

  @weekday_tab_name "WKDY headways and runtimes"
  @saturday_tab_name "SAT headways and runtimes"
  @sunday_tab_name "SUN headways and runtimes"

  @headers_regex [
    ~r/Start time/,
    ~r/End time/,
    ~r/Headway/,
    ~r/Running time\s\(Direction 0,/,
    ~r/Running time\s\(Direction 1,/
  ]

  @spec extract_data_from_upload(%{:path => binary(), optional(any()) => any()}) ::
          {:ok, {:error, list()} | {:ok, list()}}
  @doc """
  Parses a shuttle activation xlsx worksheet and returns a list of data
  """
  def extract_data_from_upload(%{path: xlsx_path}) do
    with tids when is_list(tids) <- Xlsxir.multi_extract(xlsx_path),
         {:ok, tab_map} <- get_xlsx_tab_tids(tids),
         {:ok, data} <- parse_tabs(tab_map) do
      {:ok, {:ok, data}}
    else
      {:error, error} -> {:ok, {:error, error |> Enum.map(&error_to_error_message/1)}}
    end
  end

  def error_to_error_message({tab_name, errors}) when is_list(errors) do
    ["#{tab_name}" | errors |> Enum.map(&error_to_error_message/1)]
  end

  def error_to_error_message({idx, {:error, row_data}}) when is_list(row_data) do
    row_errors = Enum.into(row_data, %{}) |> Enum.map(fn {k, v} -> "#{error_type(k)}: #{v}" end)
    "Row #{idx}, #{row_errors}"
  end

  def error_to_error_message({idx, {:error, row_error}}) do
    "Row #{idx}, #{row_error}"
  end

  def error_to_error_message(error) do
    error
  end

  def error_type(:start_time), do: "Start Time"
  def error_type(:end_time), do: "End Time"
  def error_type(:headway), do: "Headway"
  def error_type(:running_time), do: "Running Time"
  def error_type(error), do: error

  @spec get_xlsx_tab_tids(any()) :: {:error, list(String.t())} | {:ok, map()}
  def get_xlsx_tab_tids(tab_tids) do
    all_tabs = [@weekday_tab_name, @saturday_tab_name, @sunday_tab_name]

    tab_map =
      Enum.reduce(tab_tids, %{}, fn {:ok, tid}, acc ->
        name = Xlsxir.get_info(tid, :name)

        if name in all_tabs do
          Map.put(acc, name, tid)
        else
          Xlsxir.close(tid)
          acc
        end
      end)

    case Enum.empty?(Map.keys(tab_map)) do
      true ->
        {:error, ["Missing tab(s), none found for: #{Enum.join(all_tabs, ", ")}"]}

      false ->
        {:ok, tab_map}
    end
  end

  @spec parse_tabs(any()) :: {:error, [...]} | {:ok, list()}
  def parse_tabs(tab_map) do
    tab_map
    |> Enum.map(&parse_tab/1)
    |> Enum.split_with(&(elem(&1, 0) == :ok))
    |> case do
      {rows, []} -> {:ok, rows |> Enum.map(&elem(&1, 1))}
      {_, errors} -> {:error, errors |> Enum.map(&elem(&1, 1))}
    end
  end

  @spec parse_tab({any(), atom() | :ets.tid()}) ::
          {:error, {any(), [...]}} | {:ok, {any(), list()}}
  def parse_tab({tab_name, tab_id}) do
    tab = get_tab(tab_id)

    with {:ok, _headers} <- validate_headers(tab),
         {:ok, runtimes} <- parse_sheet(tab),
         {:ok, _runtimes_with_first_last} <- validate_first_last(runtimes) do
      {:ok, {tab_name, runtimes}}
    else
      {:error, error} ->
        {:error, {tab_name, error}}
    end
  end

  @spec get_tab(atom() | :ets.tid()) :: list()
  def get_tab(tab_id) do
    tab_id
    |> Xlsxir.get_list()
    # Cells that have been touched but are empty can return nil
    |> Enum.reject(fn list -> Enum.all?(list, &is_nil/1) end)
    |> tap(fn _ -> Xlsxir.close(tab_id) end)
  end

  defp header_to_string(header_regex) do
    header_regex
    |> Regex.source()
    |> String.replace("\\s\\(", " (")
    |> String.replace("0,", "0, ...)")
    |> String.replace("1,", "1, ...)")
  end

  @spec validate_headers(nonempty_maybe_improper_list()) ::
          {:error, list(String.t())} | {:ok, list()}
  def validate_headers([headers | _]) do
    @headers_regex
    |> Enum.zip(headers)
    |> Enum.map(&{&1, String.match?(elem(&1, 1), elem(&1, 0))})
    |> Enum.split_with(&elem(&1, 1))
    |> case do
      {headers, []} ->
        {:ok, headers |> Enum.map(fn {key, _val} -> elem(key, 1) end)}

      {_, missing} ->
        headers_str = @headers_regex |> Enum.map_join(", ", &header_to_string/1)

        missing_header =
          missing
          |> Enum.map(fn {key, _val} -> elem(key, 0) end)
          |> Enum.map(&header_to_string/1)
          |> List.first()

        {:error,
         ["Invalid header: column not found for #{missing_header}. expected: #{headers_str}"]}
    end
  end

  @spec validate_first_last(any()) :: {:error, list(String.t())} | {:ok, list()}
  def validate_first_last(runtimes) do
    trips =
      runtimes
      |> Enum.map(&has_first_last_trip_times?/1)
      |> Enum.filter(&elem(&1, 0))
      |> Enum.map(&elem(&1, 1))

    first? = Enum.member?(trips, :first)
    last? = Enum.member?(trips, :last)

    if first? && last? do
      {:ok, trips}
    else
      values = [{first?, "First"}, {last?, "Last"}] |> Enum.reject(&elem(&1, 0))

      {:error, ["Missing row for #{values |> Enum.map_join(" and ", &elem(&1, 1))} trip times"]}
    end
  end

  @spec has_first_last_trip_times?(any()) :: {false, :none} | {true, :first | :last}
  def has_first_last_trip_times?(%{first_trip_0: _, first_trip_1: _}) do
    {true, :first}
  end

  def has_first_last_trip_times?(%{last_trip_0: _, last_trip_1: _}) do
    {true, :last}
  end

  def has_first_last_trip_times?(_) do
    {false, :none}
  end

  @spec parse_sheet(nonempty_maybe_improper_list()) :: {:error, list()} | {:ok, list(map)}
  def parse_sheet([_headers | data] = _tab) do
    data
    |> Enum.with_index(fn r, i -> {i + 2, r |> parse_row() |> validate_row()} end)
    |> Enum.split_with(fn {_i, r} -> elem(r, 0) == :ok end)
    |> case do
      {rows, []} -> {:ok, rows |> Enum.map(fn {_idx, {:ok, data}} -> Map.new(data) end)}
      {_, errors} -> {:error, errors}
    end
  end

  def validate_row({:error, error}) do
    {:error, error}
  end

  def validate_row(row) do
    row
    |> Enum.split_with(fn {_k, v} -> elem(v, 0) == :ok end)
    |> case do
      {rows, []} -> {:ok, rows |> Enum.map(fn {k, v} -> {k, elem(v, 1)} end)}
      {_, errors} -> {:error, errors |> Enum.map(fn {k, v} -> {k, elem(v, 1)} end)}
    end
  end

  @spec parse_row(any()) :: {:error, any()} | {:ok, any()}
  def parse_row([nil, nil, nil, "First " <> trip_0, "First " <> trip_1]) do
    %{
      first_trip_0: parse_time(trip_0),
      first_trip_1: parse_time(trip_1)
    }
  end

  def parse_row([nil, nil, nil, "Last " <> trip_0, "Last " <> trip_1]) do
    %{
      last_trip_0: parse_time(trip_0),
      last_trip_1: parse_time(trip_1)
    }
  end

  def parse_row([start_time, end_time, headway, running_time_0, running_time_1]) do
    %{
      start_time: parse_time(start_time),
      end_time: parse_time(end_time),
      headway: parse_number(headway),
      running_time_0: parse_number(running_time_0),
      running_time_1: parse_number(running_time_1)
    }
  end

  def parse_row(invalid_row) do
    {:error, "malformed row: #{inspect(invalid_row)}"}
  end

  @spec parse_time(binary()) :: {:error, binary()} | {:ok, Time.t()}
  def parse_time(time_string) do
    time_string = time_string <> ":00"
    hr_min_sec = String.split(time_string, ":") |> Enum.map(&String.to_integer/1)

    if time_after_midnight?(hr_min_sec) do
      seconds = parse_time_as_seconds(hr_min_sec)
      {:ok, Time.from_seconds_after_midnight(rem(seconds, 86_400))}
    else
      case Time.from_iso8601(time_string) do
        {:ok, time} ->
          {:ok, time}

        {:error, _error} ->
          {:error, "invalid time: #{time_string}"}
      end
    end
  end

  @spec time_after_midnight?(any()) :: boolean()
  def time_after_midnight?([hr, _min, _sec]) when hr >= 24 do
    true
  end

  def time_after_midnight?(_) do
    false
  end

  @spec parse_time_as_seconds(list(integer())) :: number()
  def parse_time_as_seconds([hr, min, _sec]) do
    hr * 3600 + min * 60
  end

  @spec parse_number(any()) :: {:error, any()} | {:ok, number()}
  def parse_number(value) do
    case is_number(value) do
      true -> {:ok, value}
      false -> {:error, value}
    end
  end
end
