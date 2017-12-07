describe SearchEngine::FindCar::Free do
  let(:trip) { Factory[:trip, departure: pending_trip_departure] }
  let(:pending_trip_departure) { Sequel.pg_array([49.441655, 32.065358]) }
  let(:result) { described_class.(trip_id: trip.id) }

  before { stub_request(:any, /maps.googleapis.com/).to_return body: recorded_request_for(:success_with_in_traffic) }

  describe '.call' do
    it { expect(result).to be nil}

    context 'when nearest car was found' do
      let!(:car_1) { Factory[:car, status: Constants::Car::FREE] }
      let!(:car_2) { Factory[:car, status: Constants::Car::FREE] }
      let(:redis) { Redis.new }

      before do
        redis.set("car_#{car_1.id}", '49.461655, 32.165358')
        redis.set("car_#{car_2.id}", '50.361655, 33.165358')
      end

      it { expect(result).to include(car_id: car_1.id) }
    end
  end
end
