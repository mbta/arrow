defmodule ArrowWeb.DisruptionControllerTest do
  use ArrowWeb.ConnCase, async: true

  alias Arrow.{Disruption, DisruptionRevision, Repo}
  import Arrow.Factory

  @moduletag :authenticated

  describe "index/2" do
    test "lists disruptions", %{conn: conn} do
      [%{disruption_id: id1}, %{disruption_id: id2}] =
        Enum.map(0..1, fn _ -> insert_revision_with_everything() end)

      resp = conn |> get(Routes.disruption_path(conn, :index)) |> html_response(200)

      assert resp =~ "#{id1}"
      assert resp =~ "#{id2}"
    end
  end

  describe "show/2" do
    test "shows a disruption", %{conn: conn} do
      %{disruption_id: id} = insert_revision_with_everything()

      resp = conn |> get(Routes.disruption_path(conn, :show, id)) |> html_response(200)

      assert resp =~ "#{id}"
    end
  end

  describe "new/2" do
    test "shows a form for creating a new disruption", %{conn: conn} do
      resp = conn |> get(Routes.disruption_path(conn, :new)) |> html_response(200)

      assert resp =~ "create new disruption"
    end
  end

  describe "edit/2" do
    test "shows a form for editing a disruption", %{conn: conn} do
      %{disruption_id: id} = insert_revision_with_everything()

      resp = conn |> get(Routes.disruption_path(conn, :edit, id)) |> html_response(200)

      assert resp =~ "edit disruption"
      assert resp =~ "#{id}"
    end
  end

  describe "create/2" do
    test "creates a new disruption", %{conn: conn} do
      params = %{
        "revision" => %{
          "start_date" => "2021-01-01",
          "end_date" => "2021-01-07",
          "row_approved" => "false",
          "description" => "a testing disruption",
          "days_of_week" => %{
            "0" => %{"day_name" => "friday", "start_time" => "20:45:00"},
            "1" => %{"day_name" => "saturday"}
          },
          "exceptions" => [%{"excluded_date" => "2021-01-02"}]
        }
      }

      location = conn |> post(Routes.disruption_path(conn, :create), params) |> redirected_to()

      %{id: id} = Repo.one!(Disruption)
      assert location == Routes.disruption_path(conn, :show, id)
    end

    test "fails to create a new disruption", %{conn: conn} do
      params = %{"revision" => %{"start_date" => "2021-01-01", "end_date" => "2021-01-07"}}

      resp = conn |> post(Routes.disruption_path(conn, :create), params) |> html_response(200)

      refute Repo.one(Disruption)
      assert resp =~ "Days of week must be selected"
    end
  end

  describe "update/2" do
    test "updates a disruption", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      params = %{"revision" => string_params_for(:disruption_revision, start_date: "2021-01-02")}

      location = conn |> put(Routes.disruption_path(conn, :update, id), params) |> redirected_to()

      assert %{start_date: ~D[2021-01-02]} =
               Repo.get!(DisruptionRevision, Disruption.latest_revision_id(id))

      assert location == Routes.disruption_path(conn, :show, id)
    end

    test "fails to update a disruption", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, start_date: ~D[2021-01-01])
      params = %{"revision" => string_params_for(:disruption_revision, start_date: "")}

      resp = conn |> put(Routes.disruption_path(conn, :update, id), params) |> html_response(200)

      assert Repo.one(DisruptionRevision)
      assert resp =~ "Start date can&#39;t be blank"
    end

    test "deletes all records for an omitted association", %{conn: conn} do
      %{disruption_id: id} =
        insert(:disruption_revision,
          start_date: ~D[2021-01-01],
          end_date: ~D[2021-01-07],
          exceptions: [build(:exception, excluded_date: ~D[2021-01-03])]
        )

      params = %{
        "revision" => string_params_for(:disruption_revision) |> Map.delete("exceptions")
      }

      _ = conn |> put(Routes.disruption_path(conn, :update, id), params) |> redirected_to()

      assert %{exceptions: []} =
               Repo.get!(DisruptionRevision, Disruption.latest_revision_id(id))
               |> Repo.preload(:exceptions)
    end
  end

  describe "delete/2" do
    test "soft-deletes a disruption", %{conn: conn} do
      %{disruption_id: id} = insert(:disruption_revision, is_active: true)

      redirect = conn |> delete(Routes.disruption_path(conn, :delete, id)) |> redirected_to()

      assert redirect =~ Routes.disruption_path(conn, :show, id)
      refute Repo.get!(DisruptionRevision, Disruption.latest_revision_id(id)).is_active
    end
  end

  defp insert_revision_with_everything do
    insert(:disruption_revision,
      adjustments: [build(:adjustment)],
      days_of_week: [build(:day_of_week)],
      exceptions: [build(:exception)],
      trip_short_names: [build(:trip_short_name)]
    )
  end
end
