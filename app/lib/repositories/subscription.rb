module Repositories
  class Subscription < ROM::Repository[:subscriptions]
    relations :subscriptions

    commands :create

    def initialize
      super(ROM.env)
    end
  end
end
