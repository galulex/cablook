describe SearchEngine::FindCar::Busies do
  let(:trip) { Factory[:trip, departure: pending_trip_departure] }
  let(:pending_trip_departure) { Sequel.pg_array([49.441655, 32.065358]) }
  let(:car) { Factory[:car] }
  let(:result) { described_class.(trip_id: trip.id) }

  describe '.call' do
    it { expect(result).to be nil }

    context 'when 1 car was found' do
      let(:destination) { Sequel.pg_array([49.461655, 32.165358]) }
      let!(:trip_1) { Factory[:trip, status: Constants::Trip::DRIVING, estimated_end_time: 4.minutes.since, car_id: car.id, destination: destination] }

      it { expect(result.size).to eq(1) }
      it { expect(result.first).to include(car_id: car.id) }
    end

    context 'when a few cars were found' do
      def trip_params(estimated_interval = 0)
        {
          status: Constants::Trip::DRIVING,
          estimated_end_time: estimated_interval.minutes.since,
          destination: destination,
          car_id: Factory[:car].id
        }
      end
      let!(:trip_1) { Factory[:trip, trip_params(4)] }
      let!(:trip_2) { Factory[:trip, trip_params(8)] }
      let!(:trip_3) { Factory[:trip, trip_params(12)] }
      let!(:trip_4) { Factory[:trip, trip_params(16)] }
      let(:destination) { Sequel.pg_array([49.449907, 32.064315]) }

      it { expect(result.size).to eq(3) }
    end

    # TODO: expect situation when NearestCar return nil
  end
end
