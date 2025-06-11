defmodule ArrowWeb.TryApiTokenAuth.Keycloak do
  @moduledoc """
  Signs in an API client via Keycloak.
  """

  require Logger

  def sign_in(conn, auth_token) do
    with {:ok, user_id} <- lookup_user_id(auth_token.username),
         {:ok, roles} <- lookup_user_roles(user_id) do
      Guardian.Plug.sign_in(conn, ArrowWeb.AuthManager, auth_token.username, %{roles: roles}, ttl: {0, :second})
    else
      other ->
        Logger.warning("unexpected response when logging #{auth_token.username} in via Keycloak API: #{inspect(other)}")

        conn
    end
  end

  defp lookup_user_id(email) do
    case keycloak_api("/users", %{
           max: 1,
           email: String.downcase(email),
           exact: true,
           briefRepresentation: true
         }) do
      {:ok, [%{"id" => user_id}]} ->
        {:ok, user_id}

      {:ok, _} ->
        {:error, :missing_user}

      e ->
        e
    end
  end

  defp lookup_user_roles(user_id) do
    client_uuid = Application.get_env(:arrow, :keycloak_client_uuid)
    url = "/users/#{user_id}/role-mappings/clients/#{client_uuid}/composite"

    case keycloak_api(url) do
      {:ok, response} ->
        roles = for r <- response, do: r["name"]
        {:ok, roles}

      e ->
        e
    end
  end

  defp keycloak_api(url, params \\ %{}) do
    base_url =
      String.replace_suffix(
        Application.get_env(:arrow, :keycloak_api_base),
        "/",
        ""
      )

    {_, base_opts} = Application.get_env(:ueberauth, Ueberauth)[:providers][:keycloak]
    runtime_opts = Application.get_env(:ueberauth_oidcc, :providers)[:keycloak]

    opts =
      base_opts
      |> Keyword.merge(runtime_opts)
      |> Map.new()

    http_module = Application.get_env(:arrow, :http_client)
    oidcc_module = Map.get(opts, :module, Oidcc)

    with {:ok, token} <-
           oidcc_module.client_credentials_token(
             opts.issuer,
             opts.client_id,
             opts.client_secret,
             %{}
           ),
         headers = [{"authorization", "Bearer #{token.access.token}"}],
         {:ok, %{status_code: 200} = response} <-
           http_module.get("#{base_url}#{url}", headers,
             params: params,
             hackney: [
               ssl_options:
                 Keyword.put(
                   :httpc.ssl_verify_host_options(true),
                   :versions,
                   [:"tlsv1.3", :"tlsv1.2"]
                 )
             ]
           ) do
      Jason.decode(response.body)
    else
      {:ok, %{status_code: _} = response} -> {:error, response}
      e -> e
    end
  end
end
