defmodule Arrow.Integration.DisruptionsV2Test do
  use ExUnit.Case
  use Wallaby.Feature
  import Wallaby.Browser, except: [text: 1]
  import Wallaby.Query
  import Arrow.{DisruptionsFixtures, LimitsFixtures}

  @moduletag :integration

  feature "can view disruption on home page", %{session: session} do
    disruption =
      create_disruption(%{start_date: ~D[2024-12-31], end_date: ~D[2025-01-01]}, %{
        start_date: ~D[2024-01-01],
        end_date: ~D[2024-12-01]
      })

    session
    |> visit("/")
    |> click(link("include past"))
    |> assert_text(disruption.title)
    |> assert_text("01/01/24")
    |> assert_text("01/01/25")
  end

  feature "shows N/A dates if no limits or replacement service", %{session: session} do
    disruption_v2_fixture()

    session
    |> visit("/")
    |> assert_text("N/A")
    |> assert_text("N/A")
  end

  defp create_disruption(limit_attrs, replacement_service_attrs) do
    disruption_v2 = disruption_v2_fixture()
    limit = limit_fixture(Map.put_new(limit_attrs, :disruption_id, disruption_v2.id))
    day_of_week = limit_day_of_week_fixture(limit_id: limit.id)

    replacement_service =
      replacement_service_fixture(
        Map.put_new(replacement_service_attrs, :disruption_id, disruption_v2.id)
      )

    struct(disruption_v2,
      limits: [struct(limit, limit_day_of_weeks: [day_of_week])],
      replacement_services: [struct(replacement_service)]
    )
  end
end
