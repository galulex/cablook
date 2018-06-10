class Driver < ApplicationRecord
  belongs_to :car, required: false
  has_secure_password
  has_secure_token :auth_token

  alias_attribute :password_digest, :encrypted_password
end
