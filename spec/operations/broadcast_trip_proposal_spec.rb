describe Operations::BroadcastTripProposal do
  describe '.call' do
    subject { -> { described_class.call(cars: cars, trip_id: trip.id) } }

    let(:car) { create(:car, status: 0) }
    let(:cars) { [car.id] }
    let(:trip) { create(:trip) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          Constants::Channels::DRIVER_MAP,
          action: Constants::BroadcastActions::TRIP_PROPOSE,
          cars: cars,
          trip: Presenters::Trips::Detailed.new(trip).to_json
        ).once
        subject.call
      end
    end
  end
end
