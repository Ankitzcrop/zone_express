Geocoder.configure(
  timeout: 10,
  lookup: :nominatim,
  units: :km,
  http_headers: {
    "User-Agent" => "ZoneExpress Rails App"
  }
)
