defmodule Arrow.Disruptions.DisruptionV2Test do
  use Arrow.DataCase

  alias Arrow.Disruptions.DisruptionV2

  import Arrow.Factory

  describe "changeset/2" do
    setup {Test.Support.GtfsHelper, :insert_subway_line}

    @tag subway_line: "line-Blue"
    test "can set as approved if all replacement services use active shuttles" do
      shuttle1 = insert(:shuttle, disrupted_route_id: "Blue", status: :active)
      shuttle2 = insert(:shuttle, disrupted_route_id: "Blue", status: :active)

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

    @tag subway_line: "line-Blue"
    test "can't set as approved if any replacement service uses a non-active shuttle" do
      shuttle1 =
        insert(:shuttle,
          shuttle_name: "draft_shuttle",
          disrupted_route_id: "Blue",
          status: :draft
        )

      shuttle2 =
        insert(:shuttle,
          disrupted_route_id: "Blue",
          status: :active
        )

      replacement_services = [
        insert(:replacement_service, shuttle: shuttle1),
        insert(:replacement_service, shuttle: shuttle2),
        insert(:replacement_service, shuttle: shuttle2)
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

      assert %Ecto.Changeset{
               valid?: false,
               errors: [
                 is_active:
                   {~S|the following shuttle(s) used by this disruption must be set as 'active' first: "draft_shuttle"|,
                    []}
               ]
             } =
               DisruptionV2.changeset(disruption, %{is_active: true})
    end
  end
end
