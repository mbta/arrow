{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, ArrowWeb.Endpoint.url())
ExUnit.start(exclude: [:integration])
Ecto.Adapters.SQL.Sandbox.mode(Arrow.Repo, :manual)
Mox.defmock(Arrow.OpenRouteServiceAPI.MockClient, for: Arrow.OpenRouteServiceAPI.Client)

Application.put_env(:arrow, Arrow.OpenRouteServiceAPI,
  client: Arrow.OpenRouteServiceAPI.MockClient
)
