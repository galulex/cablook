class Driver < ApplicationRecord
  belongs_to :car, required: false
  has_secure_password
  has_secure_token :auth_token

  alias_attribute :password_digest, :encrypted_password

  validates :username, presence: true, uniqueness: true
  validates :name, :encrypted_password, presence: true

  before_validation :set_address_location, on: %i[create update]

  private

  def set_address_location
    if address.blank?
      self.address_location = []
    else
      location = Geokit::Geocoders::GoogleGeocoder.geocode("#{address}, Cherkassy")
      self.address_location = [location.lat, location.lng]
    end
  end
end
