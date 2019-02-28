module Constants
  module Regex
    EMAIL = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
    PHONE_NUMBER = /\A\+380(39|50|63|66|67|68|73|91|92|93|94|95|96|97|98|99)[0-9]{7}\z/
    LOCATION_COORDINATES = /\A\d{2}\.\d+\,\d{2}\.\d+\z/
  end
end
