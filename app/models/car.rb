class Car < ApplicationRecord
  has_one :driver

  validates :number, presence: true, uniqueness: true

  def display_name
    number
  end
end
