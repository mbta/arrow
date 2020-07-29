defmodule ArrowWeb.TryApiTokenAuth do
  import Plug.Conn
  require Logger

  @aws_cognito_target "AWSCognitoIdentityProviderService"

  def init(options), do: options

  def call(conn, _opts) do
    api_key_values = get_req_header(conn, "x-api-key")

    if api_key_values == [] do
      conn
    else
      [token | _] = api_key_values
      token = String.downcase(token)

      auth_token = Arrow.Repo.get_by(Arrow.AuthToken, token: token)

      if is_nil(auth_token) do
        conn |> send_resp(401, "unauthenticated") |> halt()
      else
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

        group_names =
          case apply(module, function, [operation]) do
            {:ok, %{"Groups" => groups}} ->
              Enum.map(groups, & &1["GroupName"])

            response ->
              :ok = Logger.warn("unexpected_aws_api_response: #{inspect(response)}")
              []
          end

        conn
        |> Guardian.Plug.sign_in(
          ArrowWeb.AuthManager,
          auth_token.username,
          %{groups: group_names}
        )
        |> Plug.Conn.put_session(:arrow_username, auth_token.username)
      end
    end
  end

  @spec config_value(binary() | {module(), atom(), [any()]}) :: any()
  defp config_value(value) when is_binary(value), do: value
  defp config_value({m, f, a}), do: apply(m, f, a)
end
