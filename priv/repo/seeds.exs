# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Arrow.Repo.insert!(%Arrow.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Arrow.Repo
alias Arrow.Gtfs
alias Arrow.Shuttles.{Shape, Stop, Shuttle, Route, RouteStop}

# For testing locally with dependency on /import-gtfs
Repo.insert(%Gtfs.Route{
  id: "Red-dev",
  agency: %Gtfs.Agency{id: "1", name: "MBTA", url: "https://www.mbta.com", timezone: "ETC"},
  short_name: nil,
  long_name: "Red Line",
  desc: "Rapid Transit",
  type: :heavy_rail,
  url: "https://www.mbta.com/schedules/Red",
  color: "DA291C",
  text_color: "FFFFFF",
  sort_order: 10010,
  fare_class: "Rapid Transit",
  line: %Gtfs.Line{
    id: "line-Red",
    short_name: "Red",
    long_name: "Red line",
    desc: "Red line subway",
    color: "Red",
    text_color: "Red",
    sort_order: 0
  },
  listed_route: nil,
  network_id: "rapid_transit"
})

Repo.insert(%Gtfs.Stop{
  id: "141",
  desc: "Alewife - Busway",
  lat: 42.395752,
  lon: -71.141584,
  location_type: :stop_platform,
  municipality: "Cambridge",
  name: "Alewife",
  platform_name: "Busway",
  vehicle_type: :bus,
  wheelchair_boarding: :accessible
})

Repo.insert(%Gtfs.Stop{
  id: "2581",
  at_street: "Highland Avenue",
  lat: 42.39693,
  lon: -71.122971,
  location_type: :stop_platform,
  municipality: "Somerville",
  name: "Holland St @ Dover St",
  on_street: "Holland St",
  vehicle_type: :bus,
  wheelchair_boarding: :accessible
})

Repo.insert(%Gtfs.Stop{
  id: "110",
  at_street: "Holyoke Street",
  lat: 42.373111,
  lon: -71.117653,
  location_type: :stop_platform,
  municipality: "Cambridge",
  name: "Massachusetts Ave opp Holyoke St",
  on_street: "Massachusetts Avenue",
  vehicle_type: :bus,
  wheelchair_boarding: :accessible
})

Repo.insert(%Gtfs.Stop{
  id: "23151",
  at_street: "Upland Road",
  lat: 42.388034,
  lon: -71.119253,
  location_type: :stop_platform,
  municipality: "Cambridge",
  name: "Massachusetts Ave @ Porter Red Line Sta",
  on_street: "Massachusetts Avenue",
  vehicle_type: :bus,
  wheelchair_boarding: :accessible
})

Repo.insert(%Gtfs.Stop{
  id: "5104",
  at_street: "College Avenue",
  desc: "Davis - Busway",
  lat: 42.396646,
  lon: -71.121879,
  location_type: :stop_platform,
  municipality: "Somerville",
  name: "Davis",
  on_street: "Busway",
  vehicle_type: :bus,
  wheelchair_boarding: :accessible
})

Repo.insert!(%Shape{
  id: 1,
  name: "AlewifeToHarvardViaBrattle-S",
  bucket: "mbta-arrow",
  path: "dev/local/shape-uploads/AlewifeToHarvardViaBrattle-S.kml",
  prefix: "shape_uploads/"
})

Repo.insert!(%Shape{
  id: 2,
  name: "AlewifeToHarvardViaBrattle-Alewife-S",
  bucket: "mbta-arrow",
  path: "dev/local/shape-uploads/AlewifeToHarvardViaBrattle-Alewife-S.kml",
  prefix: "shape_uploads/"
})

shuttle =
  Repo.insert!(%Shuttle{
    status: :draft,
    shuttle_name: "AlewifeToHarvardViaBrattle",
    disrupted_route_id: "Red-dev"
  })

route =
  Repo.insert!(%Route{
    shuttle_id: shuttle.id,
    shape_id: 1,
    destination: "Harvard",
    direction_id: :"0",
    direction_desc: :South,
    suffix: nil,
    waypoint: "Brattle"
  })

route1 =
  Repo.insert!(%Route{
    shuttle_id: shuttle.id,
    shape_id: 2,
    destination: "Alewife",
    direction_id: :"1",
    direction_desc: :North,
    suffix: nil,
    waypoint: "Brattle"
  })

Repo.insert!(%Stop{
  id: 1,
  stop_id: "9070065",
  stop_name: "Porter - Massachusetts Avenue @ Mount Vernon St",
  stop_desc:
    "Porter - Red Line Ashmont/Braintree Shuttle - Massachusetts Avenue @ Mount Vernon St",
  platform_code: nil,
  platform_name: "Ashmont/Braintree Shuttle",
  parent_station: nil,
  level_id: nil,
  zone_id: nil,
  stop_lat: 42.38758,
  stop_lon: -71.11934,
  municipality: "Cambridge",
  stop_address: nil,
  on_street: "Massachusetts Avenue",
  at_street: "Mount Vernon Street"
})

Repo.insert!(%Stop{
  id: 2,
  stop_id: "9070072",
  stop_name: "Harvard - Brattle St @ Palmer St",
  stop_desc: "Harvard - Red Line Shuttle - Brattle St @ Palmer St",
  platform_code: nil,
  platform_name: "Red Line Shuttle",
  parent_station: nil,
  level_id: nil,
  zone_id: nil,
  stop_lat: 42.373396,
  stop_lon: -71.1202,
  municipality: "Cambridge",
  stop_address: nil,
  on_street: "Brattle Street",
  at_street: "Palmer Street"
})

#   direction_id=0
#   route="Shuttle-AlewifeHarvardViaBrattle"
#   start_stop="70061"
#   end_stop="70067"
Repo.insert!(%RouteStop{
  direction_id: :"0",
  stop_sequence: 0,
  gtfs_stop_id: "141",
  time_to_next_stop: 14,
  shuttle_route_id: route.id
})

Repo.insert!(%RouteStop{
  direction_id: :"0",
  stop_sequence: 1,
  gtfs_stop_id: "2581",
  time_to_next_stop: 6,
  shuttle_route_id: route.id
})

Repo.insert!(%RouteStop{
  direction_id: :"0",
  stop_sequence: 2,
  stop_id: 1,
  time_to_next_stop: 6,
  shuttle_route_id: route.id
})

Repo.insert!(%RouteStop{
  direction_id: :"0",
  stop_sequence: 3,
  stop_id: 2,
  # last shuttle stop
  time_to_next_stop: nil,
  shuttle_route_id: route.id
})

#   direction_id=1
#   route="Shuttle-AlewifeHarvardViaBrattle"
#   start_stop="70068"
#   end_stop="70061"
Repo.insert!(%RouteStop{
  direction_id: :"1",
  stop_sequence: 0,
  gtfs_stop_id: "110",
  time_to_next_stop: 8,
  shuttle_route_id: route1.id
})

Repo.insert!(%RouteStop{
  direction_id: :"1",
  stop_sequence: 1,
  gtfs_stop_id: "23151",
  time_to_next_stop: 6,
  shuttle_route_id: route1.id
})

Repo.insert!(%RouteStop{
  direction_id: :"1",
  stop_sequence: 2,
  gtfs_stop_id: "5104",
  time_to_next_stop: 13,
  shuttle_route_id: route1.id
})

Repo.insert!(%RouteStop{
  direction_id: :"1",
  stop_sequence: 3,
  gtfs_stop_id: "141",
  # last shuttle stop
  time_to_next_stop: nil,
  shuttle_route_id: route1.id
})
