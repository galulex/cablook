module Repositories
  class Payment < ROM::Repository[:payments]
    commands :create, update: :by_pk
  end
end
