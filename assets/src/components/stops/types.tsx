type Stop = {
  stop_name: string
  stop_desc: string
  stop_lat: number
  stop_lon: number
}

type GtfsStop = {
  name: string
  desc: string
  lat: number
  lon: number
}

export { Stop, GtfsStop }
