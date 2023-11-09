defmodule Fake.ExAws do
  @moduledoc false

  @spec admin_group_request(any) :: {:ok, %{optional(<<_::48>>) => [map, ...]}}
  def admin_group_request(_operation) do
    {:ok, %{"Groups" => [%{"GroupName" => "arrow-admin"}]}}
  end

  def unexpected_response(_operation) do
    {:error, :something_went_wrong}
  end
end
