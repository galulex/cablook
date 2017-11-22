# Must have refactoring and separete logic for free and busy car.
module SearchEngine
  module FindCar
    extend self

    def call(trip_id: trip_id)
      busies = SearchEngine::FindCar::Busies.(trip_id: trip_id)
      free_car = SearchEngine::FindCar::Free.(trip_id: trip_id)
      if free_car && busies
        nearest_busy_car = busies.min { |car| car[:duration] }
        result = free_car[:duration] - nearest_busy_car[:duration]
        result > 300 ? busies : free_car
      else
        free_car || busies
      end
    end
  end
end
