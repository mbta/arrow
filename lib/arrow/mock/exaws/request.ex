defmodule Arrow.Mock.ExAws.Request do
  @moduledoc """
  Provides a basic override to avoid actually talking to AWS servers when testing basic S3 functionality
  """

  def request(_) do
    {:ok, %{body: %{contents: []}}}
  end
end
