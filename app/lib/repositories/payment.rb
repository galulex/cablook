module Repositories
  class Payment < ROM::Repository[:payments]
    commands :create, update: :by_pk

    def by_id(id)
      payments.by_pk(id).one
    end

    def by_trip(trip_id)
      payments.where(trip_id: trip_id).one
    end

    def by_user(user_id)
      payments.where(user_id: user_id).to_a
    end

    def pending_by_user(user_id)
      payments.where(status: Constants::Payments::PENDING, user_id: user_id).to_a
    end

    def pending
      payments.where(status: Constants::Payments::PENDING).to_a
    end

    def nullify_card(card_id)
      payments.where(card_id: card_id).changeset(:update, card_id: nil).commit
    end
  end
end
