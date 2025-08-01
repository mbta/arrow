defmodule Arrow.Gtfs.AgencyTest do
  use Arrow.DataCase

  alias Arrow.Gtfs.Agency

  describe "database" do
    test "can insert an agency using a CSV-parsed map with all string values" do
      attrs = %{
        "id" => "mbta",
        "name" => "Mass Bay Transpo Auth",
        "url" => "mbta.com",
        "timezone" => "America/New_York"
      }

      cs = Agency.changeset(%Agency{}, attrs)

      assert {:ok, new_agency} = Repo.insert(cs)
      assert attrs["id"] == new_agency.id

      assert new_agency in Repo.all(Agency)
    end
  end
end
