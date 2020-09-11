class Device < ApplicationRecord
  ONE_SIGNAL_TOKEN_LENGTH = 36

  scope :one_signal, -> { where(platform: Constants::Device::IOS).where.not('length(token) > ?', ONE_SIGNAL_TOKEN_LENGTH) }
  scope :fcm, -> { where('platform NOT IN (?) AND length(token) > ?', Constants::Device::IOS.dup << Constants::Device::IOS_FCM, ONE_SIGNAL_TOKEN_LENGTH) }
  scope :ios_fcm, -> { where(platform: Constants::Device::IOS_FCM) }
end
