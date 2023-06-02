class ReverseGeocoding
  attr_reader :address

  def initialize(coords)
    @address = service_class.new(coords).address
  end

  private

  def service_class
    "AddressGeocoder::#{selected_geocoder}".classify.constantize
  end

  def selected_geocoder
    Settings.address_geocoder.camelcase
  end
end
