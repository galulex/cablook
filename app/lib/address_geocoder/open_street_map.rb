module AddressGeocoder
  class OpenStreetMap
    attr_reader :address

    def initialize(coords)
      lon, lat = coords.split(',')
      uri = URI("https://nominatim.openstreetmap.org/reverse?format=json&lat=#{lat}&lon=#{lon}")
      request = Net::HTTP::Get.new(uri)
      request['Referrer'] = 'app.cablook.taxi'
      request['User-Agent'] = 'Mozilla'
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(request) }
      response_body = JSON.parse(response.body)
      result = response_body.dig('address').symbolize_keys

      @address = [result[:road], result[:house_number]].compact.join(', ')
    end
  end
end
