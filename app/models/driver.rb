class Driver < ApplicationRecord
  belongs_to :car, required: false
end
