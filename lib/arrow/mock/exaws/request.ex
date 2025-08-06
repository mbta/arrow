defmodule Arrow.Mock.ExAws.Request do
  @moduledoc """
  Provides a basic override to avoid actually talking to AWS servers when testing basic S3 functionality
  """

  def request(%{path: "/test/prefix/test-show-shape.kml"}) do
    {:ok,
     %{
       body:
         ~s(<?xml version="1.0" encoding="UTF-8"?><kml xmlns="http://www.opengis.net/kml/2.2"><Folder><Placemark><name>AlewifeHarvardViaBrattle</name><LineString><coordinates>-71.1,42.1 -71.2,42.2 -71.3,42.3</coordinates></LineString></Placemark></Folder></kml>),
       headers: [],
       status_code: 200
     }}
  end

  def request(_) do
    {:ok, %{body: %{contents: []}}}
  end
end
