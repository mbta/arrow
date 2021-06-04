defmodule Fake.ExAws do
  @moduledoc false

  def arrow_group_request(_operation) do
    {:ok, %{"Groups" => [%{"GroupName" => Application.get_env(:arrow, :cognito_group)}]}}
  end

  def unexpected_response(_operation) do
    {:error, :something_went_wrong}
  end
end
