class Device < ApplicationRecord
  scope :one_signal, -> { where(platform: Constants::Device::IOS) }
  scope :fcm, -> { where.not(platform: Constants::Device::IOS) }
end
