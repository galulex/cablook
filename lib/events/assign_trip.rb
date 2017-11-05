module Events
  class AssignTrip < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:trip_id).filled(:int?)
        required(:car_id).filled(:int?)
        required(:duration).filled(:int?)
      end
    end

    def run
      assign_car_and_update_status
    end

    private

    def assign_car_and_update_status
      Repositories::Trip.new.update(trip_id, car_id: data[:car_id], status: Constants::Trip::ON_THE_WAY)
    end
  end
end
