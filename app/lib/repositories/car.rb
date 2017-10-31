module Repositories
  class Car < ROM::Repository[:cars]
    relations :cars

    commands :create

    def initialize
      super(ROM.env)
    end

    def all
      cars.to_a
    end

    def by_number(number)
      cars.where(number: number).one
    end

    def free_cars
      # TODO: Move 0 to constants
      cars.where(status: 0).to_a
    end
  end
end
