class Driver < ApplicationRecord
  DEVICE_PLATFORM_IOS = 'iOS_FCM'.freeze

  belongs_to :car, required: false
  has_many :trips

  has_secure_password
  has_secure_token :auth_token

  alias_attribute :password_digest, :encrypted_password

  validates :username, presence: true, uniqueness: true
  validates :name, :encrypted_password, presence: true
  validates :card_number, presence: true, numericality: true, length: { is: 16 }
  validates :inn, presence: true, numericality: true, uniqueness: true, length: { is: 10 }

  before_validation :set_address_location, on: %i[create update]

  scope :fcm_tokens, -> { where.not(device: nil) }
  scope :not_ios_devices, -> { fcm_tokens.where.not(device_platform: DEVICE_PLATFORM_IOS).or(where(device_platform: nil)).pluck(:device) }
  scope :ios_devices, -> { where(device_platform: DEVICE_PLATFORM_IOS).pluck(:device) }

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
