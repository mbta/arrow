defmodule ArrowWeb.AuthManager do
  @moduledoc false

  use Guardian, otp_app: :arrow

  def max_session_time do
    Application.get_env(:arrow, __MODULE__)[:max_session_time]
  end

  def idle_time do
    Application.get_env(:arrow, __MODULE__)[:idle_time]
  end

  @impl true
  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  @impl true
  def resource_from_claims(%{"sub" => username}) do
    {:ok, username}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}

  @impl true
  def verify_claims(%{"iat" => iat, "auth_time" => auth_time} = claims, _opts) do
    now = System.system_time(:second)
    # auth_time is when the user entered their password at the SSO provider
    auth_time_expires = auth_time + max_session_time()
    # iat is when the token was issued
    iat_expires = iat + idle_time()
    # did either timeout expire?
    if min(auth_time_expires, iat_expires) < now do
      {:error, {:auth_expired, claims["sub"]}}
    else
      {:ok, claims}
    end
  end
end
