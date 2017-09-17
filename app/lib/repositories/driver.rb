module Repositories
  class Driver < ROM::Repository[:drivers]
    relations :drivers

    commands :create

    def initialize
      super(ROM.env)
    end

    def all
      drivers.to_a
    end

    def by_name(name)
      drivers.where(name: name).one
    end

    def by_token(auth_token)
      drivers.where(auth_token: auth_token).one
    end
  end
end
