module Repositories
  class Car < ROM::Repository[:cars]
    commands :create, update: :by_pk, delete: :by_pk

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
      cars.with_driver.where(status: Constants::Car::FREE).to_a
    end

    def offline
      cars.where(status: Constants::Car::OFFLINE).to_a
    end

    def online
      cars.exclude(status: Constants::Car::OFFLINE).to_a
    end

    def all_with_driver
      cars.combine(:driver).to_a
    end

    def online_with_driver
      cars.exclude(status: Constants::Car::OFFLINE).combine(:driver).to_a
    end
  end
end
