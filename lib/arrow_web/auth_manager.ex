defmodule ArrowWeb.AuthManager do
  use Guardian, otp_app: :arrow

  @impl true
  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  @impl true
  def resource_from_claims(%{"sub" => username}) do
    {:ok, username}
  end

  def resource_from_claims(_), do: {:error, :invalid_claims}
end
