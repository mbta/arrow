type Stop = {
  stop_name?: string
  stop_desc?: string
  stop_lat?: number
  stop_lon?: number
  stop_id?: string
}

type GtfsStop = {
  name: string
  desc: string
  lat: number
  lon: number
  id: string
}

export { Stop, GtfsStop }
