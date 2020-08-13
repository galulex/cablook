class Device < ApplicationRecord
  ONE_SIGNAL_TOKEN_LENGTH = 36

  scope :one_signal, -> { where(platform: Constants::Device::IOS).where.not('length(token) > ?', ONE_SIGNAL_TOKEN_LENGTH) }
  scope :fcm, -> { where.not(platform: Constants::Device::IOS.dup << Constants::Device::IOS_FCM).or(where('length(token) > ?', ONE_SIGNAL_TOKEN_LENGTH)) }
  scope :ios_fcm, -> { where(platform: Constants::Device::IOS_FCM) }
end
