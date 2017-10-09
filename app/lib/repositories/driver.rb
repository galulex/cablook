module Repositories
  class Driver < ROM::Repository[:drivers]
    relations :drivers

    commands :create, update: :by_pk

    def initialize
      super(ROM.env)
    end

    def all
      drivers.to_a
    end

    def by_name(name)
      drivers.where(name: name).one
    end

    def by_car_id(car_id)
      drivers.where(car_id: car_id).one
    end
  end
end
