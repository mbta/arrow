defmodule Arrow.SyncWorkerTest do
  use Arrow.DataCase
  import Arrow.ShuttlesFixtures
  import Arrow.StopsFixtures
  import Mox

  alias Arrow.{Shuttles, Stops, SyncWorker}

  # Ensure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "perform/1" do
    test "runs sync successfully" do
      Arrow.HTTPMock
      |> expect(:get, 2, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}

        "https://test.example.com/api/shapes", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert result == :ok
    end
  end

  describe "sync_stops/0" do
    test "creates new stops that don't exist locally" do
      _existing_stop = stop_fixture(%{stop_id: "existing-stop-123"})

      api_stops = %{
        "data" => [
          %{
            "attributes" => %{
              "stop_id" => "existing-stop-123",
              "stop_name" => "Existing Stop",
              "stop_desc" => "This stop already exists",
              "stop_lat" => 42.123,
              "stop_lon" => -71.456,
              "municipality" => "Boston"
            }
          },
          %{
            "attributes" => %{
              "stop_id" => "new-stop-456",
              "stop_name" => "New Stop",
              "stop_desc" => "This is a new stop",
              "stop_lat" => 42.789,
              "stop_lon" => -71.012,
              "municipality" => "Cambridge",
              "platform_code" => "A",
              "stop_address" => "123 Test St"
            }
          }
        ]
      }

      Arrow.HTTPMock
      |> expect(:get, 2, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(api_stops)}}

        "https://test.example.com/api/shapes", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)
      assert result == :ok

      all_stops = Stops.list_stops()
      assert length(all_stops) == 2

      new_stop = Stops.get_stop_by_stop_id("new-stop-456")
      assert new_stop.stop_name == "New Stop"
      assert new_stop.municipality == "Cambridge"
      assert new_stop.platform_code == "A"
      assert new_stop.stop_address == "123 Test St"
    end

    test "handles API errors gracefully" do
      Arrow.HTTPMock
      |> expect(:get, 1, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 500}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert {:error, "HTTP 500"} = result
    end

    test "handles malformed JSON responses" do
      Arrow.HTTPMock
      |> expect(:get, 1, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: "invalid json"}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert {:error, %Jason.DecodeError{}} = result
    end

    test "continues sync on individual stop creation errors" do
      api_stops = %{
        "data" => [
          %{
            "attributes" => %{
              "stop_id" => "valid-stop",
              "stop_name" => "Valid Stop",
              "stop_desc" => "Valid stop",
              "stop_lat" => 42.123,
              "stop_lon" => -71.456,
              "municipality" => "Boston"
            }
          },
          %{
            "attributes" => %{
              "stop_id" => "invalid-stop",
              "stop_name" => nil,
              "stop_desc" => nil,
              "stop_lat" => nil,
              "stop_lon" => nil,
              "municipality" => nil
            }
          }
        ]
      }

      Arrow.HTTPMock
      |> expect(:get, 2, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(api_stops)}}

        "https://test.example.com/api/shapes", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert result == :ok

      # Valid stop should be created
      valid_stop = Stops.get_stop_by_stop_id("valid-stop")
      assert valid_stop.stop_name == "Valid Stop"

      # Invalid stop should not exist
      invalid_stop = Stops.get_stop_by_stop_id("invalid-stop")
      assert invalid_stop == nil
    end
  end

  describe "sync_shapes/0" do
    test "creates new shapes that don't exist locally" do
      _existing_shape = shape_fixture(%{name: "ExistingToPlace-S"})

      api_shapes = %{
        "data" => [
          %{
            "attributes" => %{
              "name" => "ExistingToPlace-S",
              "bucket" => "test-bucket",
              "path" => "shapes/ExistingToPlace-S.kml",
              "prefix" => "shapes/",
              "download_url" =>
                "https://test-bucket.s3.amazonaws.com/shapes/ExistingToPlace-S.kml"
            }
          },
          %{
            "attributes" => %{
              "name" => "NewToPlace-S",
              "bucket" => "test-bucket",
              "path" => "shapes/NewToPlace-S.kml",
              "prefix" => "shapes/",
              "download_url" => "https://test-bucket.s3.amazonaws.com/shapes/NewToPlace-S.kml"
            }
          }
        ]
      }

      kml_content = """
      <?xml version="1.0" encoding="UTF-8"?>
      <kml xmlns="http://www.opengis.net/kml/2.2">
        <Folder>
          <Placemark>
            <name>NewToPlace-S</name>
            <LineString>
              <coordinates>-71.1,42.3 -71.2,42.4</coordinates>
            </LineString>
          </Placemark>
        </Folder>
      </kml>
      """

      Arrow.HTTPMock
      |> expect(:get, 2, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}

        "https://test.example.com/api/shapes", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(api_shapes)}}
      end)
      |> expect(:get, 1, fn
        "https://test-bucket.s3.amazonaws.com/shapes/NewToPlace-S.kml" ->
          {:ok, %{status_code: 200, body: kml_content}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert result == :ok

      all_shapes = Shuttles.list_shapes()
      assert length(all_shapes) == 2

      new_shape = Shuttles.get_shape_by_name!("NewToPlace-S")
      assert new_shape.name == "NewToPlace-S"
      assert new_shape.bucket == "disabled"
      assert new_shape.path == "disabled"
      assert new_shape.prefix == "disabled"
    end

    test "handles shape download errors gracefully" do
      api_shapes = %{
        "data" => [
          %{
            "attributes" => %{
              "name" => "FailedDownload-S",
              "bucket" => "test-bucket",
              "path" => "shapes/FailedDownload-S.kml",
              "prefix" => "shapes/",
              "download_url" => "https://test-bucket.s3.amazonaws.com/shapes/FailedDownload-S.kml"
            }
          }
        ]
      }

      Arrow.HTTPMock
      |> expect(:get, 2, fn
        "https://test.example.com/api/shuttle-stops", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(%{"data" => []})}}

        "https://test.example.com/api/shapes", _headers ->
          {:ok, %{status_code: 200, body: Jason.encode!(api_shapes)}}
      end)
      |> expect(:get, 1, fn
        "https://test-bucket.s3.amazonaws.com/shapes/FailedDownload-S.kml" ->
          {:ok, %{status_code: 404}}
      end)

      job = %Oban.Job{args: %{}}
      result = SyncWorker.perform(job)

      assert result == :ok

      all_shapes = Shuttles.list_shapes()
      assert Enum.empty?(all_shapes)
    end
  end
end
