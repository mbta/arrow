defmodule Arrow.Neuron.Connection.Http do
  @moduledoc false
  @behaviour Neuron.Connection

  alias Neuron.{Config, ConfigUtils}

  import Neuron.Connection.Http, except: [post: 2]

  @impl Neuron.Connection
  def call(query, options),
    do:
      query
      |> post(options)
      |> handle_response(options)

  def post(query, options) do
    http_module = Application.get_env(:arrow, :http_client)

    http_module.post(
      options |> url() |> check_url(),
      query,
      build_headers(options),
      ConfigUtils.connection_options(options)
    )
  end

  defp url(options), do: Keyword.get(options, :url) || Config.get(:url)

  defp check_url(nil), do: raise(ArgumentError, message: "you need to supply an url")
  defp check_url(url), do: url

  defp build_headers(options),
    do: Keyword.merge(["Content-Type": "application/json"], headers(options))

  defp headers(options), do: Keyword.get(options, :headers, Config.get(:headers) || [])
end
