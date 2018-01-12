describe Operations::BroadcastTripProposal do
  describe '.call' do
    subject { -> { described_class.call(cars: cars, trip_id: trip.id) } }

    let(:car) { Factory[:car, status: 0] }
    let(:cars) { [car.id] }
    let(:trip) { Factory[:trip] }

    let(:driver_map_channel) { Constants::Channels::DRIVER_MAP }
    let(:driver_map_channel_params) do
      { action: Constants::BroadcastActions::TRIP_PROPOSE,
        cars: cars,
        trip: trip_repository.by_id_with_user(trip.id).to_json }
    end
  end
end
