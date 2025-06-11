defmodule ArrowWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use ArrowWeb.ConnCase, async: true`, although
  this option is not recommendded for other databases.
  """

  use ExUnit.CaseTemplate

  import Plug.Test

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      use ArrowWeb, :verified_routes

      import Phoenix.ConnTest
      import Plug.Conn

      alias ArrowWeb.Router.Helpers, as: Routes
      # The default endpoint for testing
      @endpoint ArrowWeb.Endpoint

      # Import conveniences for testing with connections
    end
  end

  setup tags do
    :ok = Sandbox.checkout(Arrow.Repo)

    if !tags[:async] do
      Sandbox.mode(Arrow.Repo, {:shared, self()})
    end

    cond do
      tags[:authenticated] ->
        {:ok, conn: build_conn("test_user", ["read-only"])}

      tags[:authenticated_admin] ->
        {:ok, conn: authenticated_admin()}

      tags[:authenticated_empty] ->
        {:ok, conn: build_conn("test_user", [])}

      true ->
        {:ok, conn: Plug.Conn.put_req_header(Phoenix.ConnTest.build_conn(), "x-forwarded-proto", "https")}
    end
  end

  @spec build_conn(String.t(), [String.t()] | []) :: Plug.Conn.t()
  defp build_conn(user, roles) do
    Phoenix.ConnTest.build_conn()
    |> Plug.Conn.put_req_header("x-forwarded-proto", "https")
    |> init_test_session(%{})
    |> Guardian.Plug.sign_in(ArrowWeb.AuthManager, user, %{roles: roles})
  end

  def authenticated_admin, do: build_conn("test_user", ["admin"])
end
