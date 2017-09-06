module Constants
  module Regex
    EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    PHONE_NUMBER = /\A\+\d{12}\z/
  end
end
