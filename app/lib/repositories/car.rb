module Repositories
  class Car < ROM::Repository[:cars]
    commands :create, update: :by_pk

    def all
      cars.to_a
    end

    def by_id(id)
      cars.by_pk(id).one
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
