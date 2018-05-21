module Repositories
  class Tip < ROM::Repository[:tips]
    commands :create, update: :by_pk, delete: :by_pk
  end
end
