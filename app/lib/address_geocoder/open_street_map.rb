module AddressGeocoder
  class OpenStreetMap
    attr_reader :address

    def initialize(coords)
      lon, lat = coords.split(',')
      url = URI("https://nominatim.openstreetmap.org/reverse?format=json&lat=#{lat}&lon=#{lon}")
      response = JSON.parse(Net::HTTP.get(url))
      result = response.dig('address').symbolize_keys

      @address = "#{result[:road]} #{result[:house_number]}"
    end
  end
end
