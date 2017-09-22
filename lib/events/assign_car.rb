module Events
  class AssignCar < BaseEvent
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
      Repositories::Driver.new.update(data[:driver_id], car_id: data[:car_id])
    end

    def validate!
      invalid!([I18n.t('assignings.errors.messages.has_already_been_taken')]) if Repositories::Driver.new.by_car_id(data[:car_id])
    end
  end
end
