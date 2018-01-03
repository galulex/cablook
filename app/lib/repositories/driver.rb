module Repositories
  class Driver < ROM::Repository[:drivers]
    commands :create, update: :by_pk

    def all
      drivers.to_a
    end

    def by_id(id)
      drivers.by_pk(id).one
    end

    def by_username(username)
      drivers.where(username: username).one
    end

    def by_car_id(car_id)
      drivers.where(car_id: car_id).one
    end

    def by_token(auth_token)
      drivers.where(auth_token: auth_token).one
    end
  end
end
