defmodule Arrow.Disruptions.DisruptionV2Test do
  use Arrow.DataCase

  alias Arrow.Disruptions.DisruptionV2

  import Arrow.Factory
  import Arrow.ShuttlesFixtures

  describe "changeset/2" do
    test "can set as approved if all replacement services use active shuttles" do
      shuttle1 = shuttle_fixture(%{status: :active}, true, true)
      shuttle2 = shuttle_fixture(%{status: :active}, true, true)

      replacement_services = [
        insert(:replacement_service, shuttle: shuttle1),
        insert(:replacement_service, shuttle: shuttle2),
        insert(:replacement_service, shuttle: shuttle2)
      ]

      disruption =
        insert(:disruption_v2,
          title: "A valid disruption",
          mode: :subway,
          is_active: false,
          description: "A valid disruption",
          limits: [],
          replacement_services: replacement_services
        )

      assert %Ecto.Changeset{valid?: true} =
               DisruptionV2.changeset(disruption, %{is_active: true})
    end

    test "can't set as approved if any replacement service uses a non-active shuttle" do
      shuttle1 = shuttle_fixture(%{status: :draft})
      shuttle2 = shuttle_fixture(%{status: :inactive})
      shuttle3 = shuttle_fixture(%{status: :active}, true, true)

      replacement_services = [
        insert(:replacement_service, shuttle: shuttle1),
        insert(:replacement_service, shuttle: shuttle2),
        insert(:replacement_service, shuttle: shuttle2),
        insert(:replacement_service, shuttle: shuttle3)
      ]

      disruption =
        insert(:disruption_v2,
          title: "An old disruption being reused",
          mode: :subway,
          is_active: false,
          description: "An old disruption being reused",
          limits: [],
          replacement_services: replacement_services
        )

      assert %Ecto.Changeset{valid?: false, errors: [is_active: {error_msg, []}]} =
               DisruptionV2.changeset(disruption, %{is_active: true})

      assert error_msg =~
               "the following shuttle(s) used by this disruption must be set as 'active' first:"

      assert error_msg =~ shuttle1.shuttle_name
      assert error_msg =~ shuttle2.shuttle_name
      refute error_msg =~ shuttle3.shuttle_name
    end
  end

  test "can't change mode on an existing disruption" do
    disruption = insert(:disruption_v2, mode: :subway)

    assert %Ecto.Changeset{valid?: false, errors: [mode: {error_msg, []}]} =
             DisruptionV2.changeset(disruption, %{mode: :commuter_rail})

    assert error_msg =~ "cannot update mode on an existing disruption"
  end
end
