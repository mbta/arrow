defmodule ArrowWeb.API.DisruptionController do
  use ArrowWeb, :controller
  alias Arrow.{Repo, Disruption}
  import Ecto.Query

  @filters ~w{min_start_date max_start_date min_end_date max_end_date}

  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, params) do
    query = params |> take_filters |> format_filters |> build_query

    render(conn, "index.json-api",
      data:
        Repo.all(query)
        |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names]),
      opts: [include: Map.get(params, "include")]
    )
  end

  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, params) do
    render(conn, "index.json-api",
      data:
        Repo.get!(Disruption, params["id"])
        |> Repo.preload([:adjustments, :days_of_week, :exceptions, :trip_short_names]),
      opts: [include: Map.get(params, "include")]
    )
  end

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    {:ok, current_time} = DateTime.now(Application.get_env(:arrow, :time_zone))
    params_data = Map.get(params, "data", %{})
    params_relationships = Map.get(params_data, "relationships", %{})

    relationships = ArrowWeb.Utilities.get_json_api_relationships(params_relationships)
    attrs = JaSerializer.Params.to_attributes(params_data)

    adjustment_labels =
      relationships
      |> Map.get("adjustments", [])
      |> Enum.map(& &1["source_label"])

    adjustments =
      Repo.all(from adj in Arrow.Adjustment, where: adj.source_label in ^adjustment_labels)

    attrs = Map.merge(attrs, relationships)
    changeset = Disruption.changeset_for_create(%Disruption{}, attrs, adjustments, current_time)

    case Repo.insert(changeset) do
      {:ok, disruption} ->
        conn
        |> put_status(201)
        |> render("show.json-api", data: disruption)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: format_errors(changeset))
    end
  end

  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, %{"id" => id} = params) do
    {:ok, current_time} = DateTime.now(Application.get_env(:arrow, :time_zone))
    params_data = Map.get(params, "data", %{})
    params_relationships = Map.get(params_data, "relationships", %{})

    relationships = ArrowWeb.Utilities.get_json_api_relationships(params_relationships)
    attrs = JaSerializer.Params.to_attributes(params_data)

    attrs = Map.merge(attrs, relationships)

    changeset =
      Disruption.changeset_for_update(
        Repo.get(Disruption, id)
        |> Repo.preload(:adjustments)
        |> Repo.preload(:days_of_week)
        |> Repo.preload(:exceptions)
        |> Repo.preload(:trip_short_names),
        attrs,
        current_time
      )

    case Repo.update(changeset) do
      {:ok, disruption} ->
        conn
        |> put_status(200)
        |> render("show.json-api", data: disruption)

      {:error, changeset} ->
        conn
        |> put_status(400)
        |> render(:errors, errors: format_errors(changeset))
    end
  end

  @spec format_field_name(atom()) :: String.t()
  def format_field_name(field) do
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
    Enum.flat_map(errors, fn {field, [err | _]} ->
      if is_binary(err) do
        [{field, err}]
      else
        take_errors(err)
      end
    end)
  end

  @spec format_errors(Ecto.Changeset.t(Arrow.Disruption.t())) :: [map()]
  defp format_errors(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn err -> format_error_message(err) end)
    |> take_errors()
    |> Enum.map(fn {field, msg} ->
      %{detail: "#{format_field_name(field)} #{msg}"}
    end)
  end

  @spec build_query([{String.t(), Date.t()}]) :: Ecto.Query.t()
  defp build_query(filters) do
    Enum.reduce(filters, from(d in Disruption), &compose_query/2)
  end

  @spec compose_query({String.t(), Date.t()}, Ecto.Query.t()) :: Ecto.Query.t()
  defp compose_query({"min_start_date", date}, query),
    do: from(d in query, where: d.start_date >= ^date)

  defp compose_query({"min_end_date", date}, query),
    do: from(d in query, where: d.end_date >= ^date)

  defp compose_query({"max_start_date", date}, query),
    do: from(d in query, where: d.start_date <= ^date)

  defp compose_query({"max_end_date", date}, query),
    do: from(d in query, where: d.end_date <= ^date)

  @spec take_filters(map()) :: map()
  defp take_filters(params) do
    Map.take(Map.get(params, "filter", %{}), @filters)
  end

  @spec format_filters(map()) :: [{String.t(), Date.t()}]
  defp format_filters(filters) do
    Enum.reduce(filters, [], fn filter, acc -> acc ++ do_format_filter(filter) end)
  end

  @spec do_format_filter({String.t(), String.t()}) :: [{String.t(), Date.t()}]
  defp do_format_filter({filter, value})
       when filter in @filters do
    case Date.from_iso8601(value) do
      {:ok, date} ->
        [{filter, date}]

      {:error, _} ->
        []
    end
  end

  defp do_format_filter(_), do: []
end
