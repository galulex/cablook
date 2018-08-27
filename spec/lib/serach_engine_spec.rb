describe SearchEngine do
  describe '.call' do
    subject { -> { described_class.call(trip_id: trip.id) } }

    let(:trip) { create(:trip) }

    context 'when trip propose is broadcasted' do
      let!(:car) { create(:car, status: Constants::Car::OFFLINE) }
      let!(:car_online) { create(:car, status: Constants::Car::FREE) }
      let!(:car_in_trip) { create(:car, status: Constants::Car::DURING_TRIP) }
      let(:car_ids) { [car_online.id, car_in_trip.id] }

      after { subject.call }

      it { expect(Operations::BroadcastTripProposal).to receive(:call).with(cars: car_ids, trip_id: trip.id) }
    end
  end
end