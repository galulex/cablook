# class to get location coordinates from address string
class Places
  URL = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?inputtype=textquery&fields=geometry&key=#{ENV['GOOGLE_API_KEY']}&input=%s Cherkasy".freeze

  attr_reader :location

  def initialize(string)
    url = URI(URI.escape(format(URL, string)))
    result = JSON.parse(Net::HTTP.get_response(url).body)
    @location = result['candidates'][0]&.dig('geometry', 'location')
  end
end
