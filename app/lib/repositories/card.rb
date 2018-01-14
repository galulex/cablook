module Repositories
  class Card < ROM::Repository[:cards]
    commands :create, update: :by_pk, delete: :by_pk

    def by_id(id)
      cards.by_pk(id).one
    end

    def by_user(user_id)
      cards.where(user_id: user_id).to_a
    end
  end
end
