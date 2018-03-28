class Driver < ApplicationRecord
  belongs_to :car, validate: false
end
