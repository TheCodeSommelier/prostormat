# frozen_string_literal: true

Geocoder.configure(
  units: :km,
  lookup: :nominatim,
  use_https: true,
  http_headers: { 'User-Agent' => 'Prostormat/1.0 (poptavka@prostormat.cz)' }
)
