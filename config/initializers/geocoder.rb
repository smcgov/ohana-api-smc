require 'readthis'

cache = Readthis::Cache.new(
  redis: {
    url: ENV.fetch('REDISCLOUD_URL', 'redis://localhost:6379'),
    driver: :hiredis
  },
  expires_in: 2.weeks.to_i
)

Geocoder.configure(
  lookup: :google,
  api_key: ENV.fetch('GOOGLE_GEOCODING_API_KEY', nil),
  use_https: true,
  cache:,
  always_raise: [
    Geocoder::OverQueryLimitError,
    Geocoder::RequestDenied,
    Geocoder::InvalidRequest,
    Geocoder::InvalidApiKey
  ]
)
