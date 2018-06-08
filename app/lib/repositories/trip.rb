module Repositories
  class Trip < ROM::Repository[:trips]
    commands :create, update: :by_pk, delete: :by_pk

    def all
      trips.to_a
    end

    def detailed(trip_id)
      trips.detailed.with_user.with_payment.by_pk(trip_id).one
    end

    def by_id(trip_id)
      trips.by_pk(trip_id).one
    end

    def by_user_and_status(user_id, status: Constants::Trip::STATUSES, page: nil, per: 5)
      trips.with_feedbacks.where(user_id: user_id, status: status).order(Sequel.desc(:id)).offset(page&.send(:*, per)).limit(page.nil? ? nil : per).to_a
    end

    def by_pk_with_feedbacks(trip_id)
      trips.by_pk(trip_id).with_feedbacks.one
    end

    def active_and_estimated_end_in_timeframe(from: Time.now, till: Time.now + 5.minutes)
      trips.active.estimated_end_in_timeframe(from, till).to_a
    end

    def by_id_with_user(trip_id)
      trips.by_pk(trip_id).with_user.one
    end

    def count_of_finished_for_user(user_id)
      trips.where(user_id: user_id, status: Constants::Trip::FINISHED).count
    end

    def currents(driver_id)
      statuses = [Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]
      trips.with_payment.where(Sequel[:trips][:driver_id] => driver_id, Sequel[:trips][:status] => statuses).with_user.detailed.to_a
    end

    def pending
      trips.where(status: Constants::Trip::PENDING).with_user.to_a
    end

    def in_progress
      statuses = [Constants::Trip::PENDING, Constants::Trip::ON_THE_WAY, Constants::Trip::WAITING_CLIENT, Constants::Trip::DRIVING]
      trips.with_user.where(status: statuses).to_a
    end

    def by_driver_and_status_beetwen_dates(driver_id, status, from:, to: Time.now)
      trips
        .where(driver_id: driver_id, status: status)
        .where(Sequel.lit('created_at BETWEEN :from AND :to', from: from, to: to))
        .to_a
    end
  end
end
