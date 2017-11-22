module Events
  class Drivers::AssignCar < BaseEvent
    def schema
      Dry::Validation.Schema do
        required(:driver_id).filled(:int?)
        required(:car_id).filled(:int?)
      end
    end

    def run
      validate!
      assign_car
    end

    private

    def assign_car
      # TODO: Add method to set car status
      driver_repository.update(data[:driver_id], car_id: data[:car_id])
    end

    def validate!
      invalid!([I18n.t('assignings.errors.messages.has_already_been_taken')]) if driver_repository.by_car_id(data[:car_id])
    end

    def driver_repository
      @driver_repository ||= Repositories::Driver.new(ROM.env)
    end
  end
end
