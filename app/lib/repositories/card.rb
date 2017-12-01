module Repositories
  class Card < ROM::Repository[:cards]
    commands :create, update: :by_pk

    def by_user(user_ids)
      cards.where(user_id: user_ids).to_a
    end
  end
end
