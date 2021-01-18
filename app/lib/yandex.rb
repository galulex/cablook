# class to get address from coordinates
class Yandex
  URL = 'https://geocode-maps.yandex.ru/1.x/?apikey=9bbf546a-a5ca-44e1-abb2-8785a76fcbb4&format=json&geocode=%s&lang=%s'.freeze

  attr_reader :address

  def initialize(coords)
    url = URI(URI.escape(format(URL, coords, I18n.locale)))
    result = JSON.parse(Net::HTTP.get_response(url).body)
    geo_object = result.dig('response', 'GeoObjectCollection', 'featureMember')&.first
    return unless geo_object

    @address = geo_object.dig('GeoObject', 'name')
  end
end
