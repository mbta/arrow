defmodule Arrow.Shuttles.StopTest do
  use Arrow.DataCase

  alias Arrow.Shuttles.Stop

  @required_stop_params %{
    stop_id: "stop_id",
    stop_name: "stop_name",
    stop_desc: "stop_desc",
    stop_lat: "42.361133",
    stop_lon: "-71.057643",
    municipality: "municipality"
  }

  @permitted_stop_params %{
    platform_code: "platform_code",
    platform_name: "platform_name",
    stop_address: "stop_address",
    zone_id: "zone_id",
    level_id: "level_id",
    parent_station: "parent_station",
    on_street: "on_street",
    at_street: "at_street"
  }

  describe "changeset/2" do
    test "casts all valid params" do
      params = Map.merge(@required_stop_params, @permitted_stop_params)

      assert %Ecto.Changeset{valid?: true} = Stop.changeset(%Stop{}, params)
    end

    test "casts valid params with only required params" do
      assert %Ecto.Changeset{valid?: true} = Stop.changeset(%Stop{}, @required_stop_params)
    end

    test "requires stop_id" do
      params =
        @required_stop_params
        |> Map.delete(:stop_id)
        |> Map.merge(@permitted_stop_params)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_id: {"can't be blank", [validation: :required]}]
             } = Stop.changeset(%Stop{}, params)
    end

    test "requires stop_desc" do
      params =
        @required_stop_params
        |> Map.delete(:stop_desc)
        |> Map.merge(@permitted_stop_params)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_desc: {"can't be blank", [validation: :required]}]
             } = Stop.changeset(%Stop{}, params)
    end

    test "requires stop_lat" do
      params =
        @required_stop_params
        |> Map.delete(:stop_lat)
        |> Map.merge(@permitted_stop_params)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_lat: {"can't be blank", [validation: :required]}]
             } = Stop.changeset(%Stop{}, params)
    end

    test "requires stop_lon" do
      params =
        @required_stop_params
        |> Map.delete(:stop_lon)
        |> Map.merge(@permitted_stop_params)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_lon: {"can't be blank", [validation: :required]}]
             } = Stop.changeset(%Stop{}, params)
    end

    test "requires municipality" do
      params =
        @required_stop_params
        |> Map.delete(:municipality)
        |> Map.merge(@permitted_stop_params)

      assert %Ecto.Changeset{
               valid?: false,
               errors: [municipality: {"can't be blank", [validation: :required]}]
             } = Stop.changeset(%Stop{}, params)
    end

    test "stop_lat and stop_lon must be convertable to float" do
      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_lat: {"is invalid", [type: :float, validation: :cast]}]
             } = Stop.changeset(%Stop{}, Map.put(@required_stop_params, :stop_lat, "invalid"))

      assert %Ecto.Changeset{
               valid?: false,
               errors: [stop_lon: {"is invalid", [type: :float, validation: :cast]}]
             } = Stop.changeset(%Stop{}, Map.put(@required_stop_params, :stop_lon, "invalid"))
    end
  end
end
