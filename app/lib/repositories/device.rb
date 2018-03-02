module Repositories
  class Device < ROM::Repository[:devices]
    commands :create, update: :by_pk, delete: :by_pk

    def by_id(id)
      devices.by_pk(id).one
    end

    def by_user(user_id)
      devices.where(user_id: user_id).one
    end
  end
end
