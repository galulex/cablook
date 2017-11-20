# Must have refactoring and separete logic for free and busy car.
module SearchEngine
  module FindCar
    def self.call(trip_id:)
      new(trip_id: trip_id).call
    end

    def initialize(trip_id:)
      @trip_id = trip_id
    end

    attr_reader :trip_id

    private

    def nearest_car
      if free_car && nearest_busy_car
        result = free_car[:duration] - nearest_busy_car[:duration]
        result > 300 ? busies : free_car
      else
        free_car || busies
      end
    end

    def free_car
      @free_car ||= SearchEngine::FindCar::Free.(trip_id: trip_id)
    end

    def busies
      @busies ||= SearchEngine::FindCar::Busies.(trip_id: trip_id)
    end

    def nearest_busy_car
      busies.min { |car| car[:duration] }
    end
  end
end
