module Trips
  class Repository < ROM::Repository[:trips]
    relations :trips

    commands :create

    def initialize
      super(ROM.env)
    end
  end
end
