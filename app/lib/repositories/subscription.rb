module Repositories
  class Subscription < ROM::Repository[:subscriptions]
    commands :create
  end
end
