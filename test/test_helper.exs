{:ok, _} = Application.ensure_all_started(:ex_machina)
{:ok, _} = Application.ensure_all_started(:wallaby)
Application.put_env(:wallaby, :base_url, ArrowWeb.Endpoint.url())
ExUnit.start(exclude: [:integration])
Ecto.Adapters.SQL.Sandbox.mode(Arrow.Repo, :manual)
