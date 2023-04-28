# class to get address from coordinates
module AddressGeocoder
  class Yandex
    URL = "#{ENV['YANDEX_GEOCODER_DOMAIN']}/?apikey=#{ENV['YANDEX_GEOCODER_API_KEY']}&format=json&geocode=%s&lang=%s".freeze

    attr_reader :address

    def initialize(coords)
      url = URI(URI.escape(format(URL, coords, I18n.locale)))
      result = JSON.parse(Net::HTTP.get_response(url).body)
      geo_object = result.dig('response', 'GeoObjectCollection', 'featureMember')&.first
      return unless geo_object

      @address = geo_object.dig('GeoObject', 'name')
    end
  end
end
