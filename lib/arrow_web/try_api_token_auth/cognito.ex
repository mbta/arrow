defmodule ArrowWeb.TryApiTokenAuth.Cognito do
  @moduledoc """
  Signs in an API client via Cognito.
  """

  require Logger

  @aws_cognito_target "AWSCognitoIdentityProviderService"
  @cognito_groups Application.compile_env!(:arrow, :cognito_groups)

  def sign_in(conn, auth_token) do
    user_pool_id =
      :ueberauth
      |> Application.get_env(Ueberauth.Strategy.Cognito)
      |> Keyword.get(:user_pool_id)
      |> config_value

    data = %{
      "Username" => auth_token.username,
      "UserPoolId" => user_pool_id
    }

    headers = [
      {"x-amz-target", "#{@aws_cognito_target}.AdminListGroupsForUser"},
      {"content-type", "application/x-amz-json-1.1"}
    ]

    operation = ExAws.Operation.JSON.new(:"cognito-idp", data: data, headers: headers)

    {module, function} = Application.get_env(:arrow, :ex_aws_requester)

    roles =
      case apply(module, function, [operation]) do
        {:ok, %{"Groups" => groups}} ->
          for %{"GroupName" => group} <- groups,
              {:ok, role} <- [Map.fetch(@cognito_groups, group)] do
            role
          end

        {:error, {"UserNotFoundException", _}} ->
          # user exists within Arrow but not Cognito (likely due to the Keycloak migration)
          []

        response ->
          :ok = Logger.warning("unexpected_aws_api_response: #{inspect(response)}")
          []
      end

    conn
    |> Guardian.Plug.sign_in(
      ArrowWeb.AuthManager,
      auth_token.username,
      %{roles: roles},
      ttl: {0, :second}
    )
  end

  @spec config_value(binary() | {module(), atom(), [any()]}) :: any()
  defp config_value(value) when is_binary(value), do: value
  defp config_value({m, f, a}), do: apply(m, f, a)
end
