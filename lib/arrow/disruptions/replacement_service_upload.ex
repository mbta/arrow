defmodule Arrow.Disruptions.ReplacementServiceUpload do
  @moduledoc "functions for extracting shuttle replacement services from xlsx uploads"
  alias Arrow.Disruptions.ReplacementServiceUpload.{
    FirstTrip,
    LastTrip,
    Runtimes
  }

  require Logger

  @version 1

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

  @type tab_name :: String.t()
  @type row_index :: integer()
  @type ok_or_error :: {:ok, String.t() | number()} | {:error, String.t()}
  @type parsed_row :: %{required(:atom) => ok_or_error()}
  @type sheet_errors :: {:error, {row_index(), parsed_row()}}
  @type sheet_data :: Runtimes.t() | FirstTrip.t() | LastTrip.t()
  @type error_tab :: {tab_name(), list(sheet_errors())}
  @type valid_tab :: {tab_name(), list(sheet_data())}
  @type versioned_data :: %{
          required(String.t()) => number(),
          required(tab_name) => list(sheet_data())
        }

  # https://github.com/jsonkenl/xlsxir?tab=readme-ov-file#considerations
  @type xlsxir_types :: String.t() | number() | NaiveDateTime.t() | :calendar.date()

  @type error_message :: String.t()
  @type error_details :: list(String.t())
  @type rescued_exception_error :: {:ok, {:error, list({error_message(), []})}}

  @doc """
  Parses a shuttle replacement service xlsx worksheet and returns a list of data
  Includes a rescue clause to catch errors while parsing user-provided data
  """
  @spec extract_data_from_upload(%{:path => binary()}) ::
          {:ok, {:error, list({error_message, error_details})} | {:ok, versioned_data()}}
          | rescued_exception_error()
  def extract_data_from_upload(%{path: xlsx_path}) do
    with tids when is_list(tids) <- Xlsxir.multi_extract(xlsx_path),
         {:ok, tab_map} <- get_xlsx_tab_tids(tids),
         {:ok, tabs} <- get_tabs(tab_map),
         {:ok, data} <- parse_tabs(tabs),
         {:ok, versioned_data} <- add_version(data) do
      {:ok, {:ok, versioned_data}}
    else
      {:error, error} ->
        {:ok, {:error, [{format_warning(), []} | error |> Enum.map(&error_to_error_message/1)]}}
    end
  rescue
    e ->
      Logger.warning(
        "ReplacementServiceUpload failed to parse XLSX, message=#{Exception.format(:error, e, __STACKTRACE__)}"
      )

      # Must be wrapped in an ok tuple for caller, consume_uploaded_entry/3
      {:ok, {:error, [{format_warning(), []}]}}
  end

  @spec error_to_error_message(error_tab()) :: tuple()
  def error_to_error_message({tab_name, errors}) when is_binary(tab_name) and is_list(errors) do
    {"#{tab_name}", errors |> Enum.map(&error_to_error_message/1)}
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

  def format_warning do
    "Please ensure that your spreadsheet matches the expected format, contact Transit Data for assistance"
  end

  def error_type(:start_time), do: "Start Time"
  def error_type(:end_time), do: "End Time"
  def error_type(:headway), do: "Headway"
  def error_type(:running_time_0), do: "Running Time"
  def error_type(:running_time_1), do: "Running Time"
  def error_type(:first_trip_0), do: "First Trip"
  def error_type(:first_trip_1), do: "First Trip"
  def error_type(:last_trip_0), do: "Last Trip"
  def error_type(:last_trip_1), do: "Last Trip"
  def error_type(error), do: error

  @spec add_version(list(valid_tab())) :: {:ok, versioned_data()}
  def add_version(data) do
    {:ok, data |> Enum.into(%{"version" => @version})}
  end

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

    if Enum.empty?(Map.keys(tab_map)) do
      {:error, [{"Missing tab(s)", ["none found for: #{Enum.join(all_tabs, ", ")}"]}]}
    else
      {:ok, tab_map}
    end
  end

  @type tab :: {tab_name(), list(xlsxir_types())}

  @spec get_tabs(map()) :: {:ok, list(tab)}
  def get_tabs(tab_map) do
    {:ok, Enum.map(tab_map, fn {tab_name, tid} -> {tab_name, get_tab_rows(tid)} end)}
  end

  @spec get_tab_rows(atom() | :ets.tid()) :: list(xlsxir_types())
  def get_tab_rows(tab_id) do
    tab_id
    |> Xlsxir.get_list()
    # Cells that have been touched but are empty can return nil
    |> Enum.reject(fn list -> Enum.all?(list, &is_nil/1) end)
    |> tap(fn _ -> Xlsxir.close(tab_id) end)
  end

  @spec parse_tabs(list(tab())) :: {:error, list(error_tab())} | {:ok, list(valid_tab())}
  def parse_tabs(tabs) do
    tabs
    |> Enum.map(&parse_tab/1)
    |> Enum.split_with(&(elem(&1, 0) == :ok))
    |> case do
      {rows, []} -> {:ok, rows |> Enum.map(&elem(&1, 1))}
      {_, errors} -> {:error, errors |> Enum.map(&elem(&1, 1))}
    end
  end

  @type parsed_tab :: {:ok, valid_tab()} | {:error, error_tab()}

  @spec parse_tab(tab) :: parsed_tab()
  def parse_tab({tab_name, rows}) do
    with {:ok, _headers} <- validate_headers(rows),
         {:ok, parsed_data} <- parse_sheet(rows),
         {:ok, first_and_last} <- ensure_first_last(parsed_data),
         :ok <- ensure_headways_from_first_to_last(parsed_data, first_and_last) do
      {:ok, {tab_name, parsed_data}}
    else
      {:error, error} ->
        {:error, {tab_name, error}}
    end
  end

  defp ensure_headways_from_first_to_last(parsed_data, first_last) do
    %{first_trip_0: first0, first_trip_1: first1} = first_last.first
    %{last_trip_0: last0, last_trip_1: last1} = first_last.last

    first_hour =
      [first0, first1]
      |> Enum.map(&time_str_to_hour/1)
      |> Enum.min()

    last_hour =
      [last0, last1]
      |> Enum.map(&time_str_to_hour/1)
      |> Enum.max()

    required_hours = MapSet.new(first_hour..last_hour//1)

    runtime_hours =
      parsed_data
      |> Enum.filter(&match?(%{start_time: _, end_time: _}, &1))
      |> Enum.flat_map(fn %{start_time: start_time, end_time: end_time} ->
        start_hour = time_str_to_hour(start_time)

        end_hour =
          if String.slice(end_time, 2..-1//1) == ":00" do
            time_str_to_hour(end_time) - 1
          else
            time_str_to_hour(end_time)
          end

        start_hour..end_hour//1
      end)
      |> MapSet.new()

    all_required_hours_have_runtimes? = MapSet.subset?(required_hours, runtime_hours)

    if all_required_hours_have_runtimes? do
      :ok
    else
      missing = Enum.sort(MapSet.difference(required_hours, runtime_hours))
      {:error, ["Missing rows for hour(s) #{Enum.map_join(missing, ", ", &hour_to_time_str/1)}"]}
    end
  end

  # E.g. "03:15" -> 3, "25:08" -> 25
  defp time_str_to_hour(time_str) do
    time_str
    |> String.slice(0..1//1)
    |> String.to_integer()
  end

  # E.g. 3 -> "03:00", 25 -> "25:00"
  defp hour_to_time_str(hour) do
    hour
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
    |> Kernel.<>(":00")
  end

  defp header_to_string(header_regex) do
    header_regex
    |> Regex.source()
    |> String.replace("\\s\\(", " (")
    |> String.replace("0,", "0, ...)")
    |> String.replace("1,", "1, ...)")
  end

  defp headers_as_string do
    @headers_regex |> Enum.map_join(", ", &header_to_string/1)
  end

  @spec validate_headers(list(xlsxir_types())) ::
          {:error, list(String.t())} | {:ok, list()}
  def validate_headers([headers | _]) when is_list(headers) do
    trunc_headers = Enum.take(headers, length(@headers_regex))

    if Enum.all?(trunc_headers, &is_binary(&1)) do
      do_validate_headers(trunc_headers)
    else
      {:error, ["Invalid headers, expected: #{headers_as_string()}"]}
    end
  end

  defp do_validate_headers(headers) do
    headers
    |> Enum.zip(@headers_regex)
    |> Enum.map(&{&1, String.match?(elem(&1, 0), elem(&1, 1))})
    |> Enum.split_with(&elem(&1, 1))
    |> case do
      {headers, []} ->
        {:ok, headers |> Enum.map(fn {key, _val} -> elem(key, 0) end)}

      {_, missing} ->
        missing_header =
          missing
          |> Enum.map(fn {key, _val} -> elem(key, 1) end)
          |> Enum.map(&header_to_string/1)
          |> List.first()

        {:error,
         [
           "Invalid header: column not found for #{missing_header}. expected: #{headers_as_string()}"
         ]}
    end
  end

  @spec ensure_first_last(list()) ::
          {:ok, %{first: FirstTrip.t(), last: LastTrip.t()}}
          | {:error, list(String.t())}
  def ensure_first_last(runtimes) do
    first_last =
      runtimes
      |> Enum.map(fn runtime ->
        case has_first_last_trip_times?(runtime) do
          {true, :first} -> {:first, runtime}
          {true, :last} -> {:last, runtime}
          {false, _} -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    first_last_map = Map.new(first_last)
    first = first_last_map[:first]
    last = first_last_map[:last]

    cond do
      length(first_last) > 2 ->
        dups =
          first_last
          |> Enum.frequencies_by(fn {k, _v} -> k end)
          |> Map.filter(fn {_k, count} -> count > 1 end)
          |> Map.keys()

        {:error, ["Duplicate row(s) for #{Enum.join(dups, " and ")} trip times"]}

      is_nil(first) or is_nil(last) ->
        values = [{first, "First"}, {last, "Last"}] |> Enum.reject(&elem(&1, 0))

        {:error, ["Missing row for #{values |> Enum.map_join(" and ", &elem(&1, 1))} trip times"]}

      first_trips_after_last?(first, last) ->
        {:error, ["First trip times must be after Last trip times"]}

      :else ->
        {:ok, first_last_map}
    end
  end

  defp first_trips_after_last?(
         %{first_trip_0: first_trip_0, first_trip_1: first_trip_1},
         %{last_trip_0: last_trip_0, last_trip_1: last_trip_1}
       ) do
    first_trip_0 > last_trip_0 or first_trip_1 > last_trip_1
  end

  @spec has_first_last_trip_times?(map) :: {false, :none} | {true, :first | :last}
  def has_first_last_trip_times?(%{first_trip_0: _, first_trip_1: _}) do
    {true, :first}
  end

  def has_first_last_trip_times?(%{last_trip_0: _, last_trip_1: _}) do
    {true, :last}
  end

  def has_first_last_trip_times?(_) do
    {false, :none}
  end

  @spec parse_sheet(list(xlsxir_types())) ::
          {:error, list(sheet_errors())} | {:ok, list(sheet_data())}
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

  @spec parse_row(list(xlsxir_types())) ::
          {:error, String.t()}
          | parsed_row()
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

  def parse_row(row) when length(row) == 5 do
    if Enum.any?(row, &is_nil(&1)) do
      {:error, invalid_row_message(row)}
    else
      [start_time, end_time, headway, running_time_0, running_time_1] = row

      %{
        start_time: parse_time(start_time),
        end_time: parse_time(end_time),
        headway: parse_number(headway),
        running_time_0: parse_number(running_time_0),
        running_time_1: parse_number(running_time_1)
      }
    end
  end

  def parse_row(invalid_row) do
    {:error, invalid_row_message(invalid_row)}
  end

  defp invalid_row_message(invalid_row) when is_list(invalid_row) do
    invalid_values =
      invalid_row |> Enum.reject(&is_nil/1) |> Enum.map(&format_xlsxir_type/1)

    "malformed row, unexpected values: #{Enum.join(invalid_values, ", ")}"
  end

  defp invalid_row_message(invalid_row) do
    "malformed row, unexpected values: #{inspect(invalid_row)}"
  end

  @spec parse_time(xlsxir_types()) ::
          {:error, String.t()} | {:ok, String.t()}
  def parse_time(%NaiveDateTime{hour: hour, minute: minute} = ndt) do
    time = NaiveDateTime.to_time(ndt)
    time_string = Time.to_string(time)

    if hour <= 3 do
      # We could make incorrect assumptions about the service day, so erroring for the user to resolve for now
      {:error,
       "invalid time: #{time_string}, expecting times after midnight as #{24 + hour}:#{String.pad_leading("#{minute}", 2, "0")}"}
    else
      parse_time(time_string)
    end
  end

  def parse_time(time_string) when is_binary(time_string) do
    with {:ok, truncated} <- truncate_seconds(time_string),
         {:ok, padded} <- pad_leading(truncated),
         {:ok, [hr, min]} <- to_time_int_list(padded),
         {:ok, _valid} <- validate_time_format([hr, min]) do
      {:ok, padded}
    else
      {:error, _time} -> {:error, "invalid time: #{time_string}"}
    end
  end

  def parse_time(time) do
    {:error, "invalid time: #{format_xlsxir_type(time)}"}
  end

  def truncate_seconds(time_string) when is_binary(time_string) do
    case String.split(time_string, ":") do
      [_hr, _min, _sec] -> {:ok, String.split(time_string, ":") |> Enum.take(2) |> Enum.join(":")}
      [_hr, _min] -> {:ok, time_string}
      _ -> {:error, time_string}
    end
  end

  def truncate_seconds(time_string) do
    {:error, time_string}
  end

  def pad_leading(time_string) when is_binary(time_string) do
    case String.length(time_string) do
      4 -> {:ok, String.pad_leading(time_string, 5, "0")}
      _ -> {:ok, time_string}
    end
  end

  def pad_leading(time_string) do
    {:error, time_string}
  end

  def to_time_int_list(time_string) when is_binary(time_string) do
    {:ok, String.split(time_string, ":") |> Enum.map(&String.to_integer/1) |> Enum.take(2)}
  end

  def to_time_int_list(time_string) do
    {:error, time_string}
  end

  def validate_time_format([hr, min]) when hr < 29 and min in 0..59 do
    {:ok, [hr, min]}
  end

  def validate_time_format(invalid_format) do
    {:error, invalid_format}
  end

  @spec parse_number(any()) :: {:error, String.t()} | {:ok, number()}
  def parse_number(value) when is_number(value) do
    {:ok, value}
  end

  def parse_number(value) do
    {:error, "invalid number: #{format_xlsxir_type(value)}"}
  end

  # Xlsxir will format datetime values as Elixir naive datetime
  defp format_xlsxir_type(%NaiveDateTime{} = ndt) do
    ndt |> NaiveDateTime.to_time() |> Time.to_string()
  end

  # Xlsxir will format date formatted values in Erlang :calendar.date() type format
  # This upload doesn't parse any Calendar dates
  defp format_xlsxir_type({_year, _month, _day} = erlang_date) do
    date =
      case Date.from_erl(erlang_date) do
        {:ok, date} -> " #{date}"
        {:error, :invalid_date} -> ""
      end

    "date#{date}"
  end

  defp format_xlsxir_type(number) when is_number(number) do
    number
  end

  defp format_xlsxir_type(string) do
    string
  end
end

defmodule Arrow.Disruptions.ReplacementServiceUpload.FirstTrip do
  @moduledoc "struct to represent parsed first trip row"
  defstruct first_trip_0: nil, first_trip_1: nil

  @type t :: %__MODULE__{
          first_trip_0: String.t(),
          first_trip_1: String.t()
        }
end

defmodule Arrow.Disruptions.ReplacementServiceUpload.LastTrip do
  @moduledoc "struct to represent parsed last trip row"
  defstruct last_trip_0: nil, last_trip_1: nil

  @type t :: %__MODULE__{
          last_trip_0: String.t(),
          last_trip_1: String.t()
        }
end

defmodule Arrow.Disruptions.ReplacementServiceUpload.Runtimes do
  @moduledoc "struct to represent parsed runtimes row"
  defstruct start_time: nil,
            end_time: nil,
            headway: nil,
            running_time_0: nil,
            running_time_1: nil

  @type t :: %__MODULE__{
          start_time: String.t(),
          end_time: String.t(),
          headway: number(),
          running_time_0: number(),
          running_time_1: number()
        }
end
