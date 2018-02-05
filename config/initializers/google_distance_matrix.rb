GoogleDistanceMatrix.configure_defaults do |config|
  config.google_api_key = ENV['GOOGLE_API_KEY']
  config.mode = 'driving'
  config.departure_time = 'now'
end
