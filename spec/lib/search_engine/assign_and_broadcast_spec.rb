describe SearchEngine::AssignAndBroadcast do
  describe '.call' do
    subject { -> { described_class.call(car_id: car.id, trip_id: trip.id, duration: duration) } }

    let!(:driver) { Factory[:driver, car_id: car.id] }
    let(:car) { Factory[:car, status: 0] }
    let(:trip) { Factory[:trip] }
    let(:duration) { 600 }

    it { is_expected.to change { trips_repository.by_id(trip.id).car_id }.from(nil).to(car.id) }
    it do
      is_expected.to change { cars_repository.by_id(car.id).status }
        .from(0)
        .to(Constants::Trip::DRIVING)
    end

    context 'and broadcasts to channel' do
      let(:trip_channel) { "#{Constants::Channels::TRIP}_#{trip.id}" }
      let(:trip_channel_params) do
        { action: 'TripAssigned',
          car_id: car.id,
          duration: duration }
      end
      let(:driver_map_channel) { Constants::Channels::DRIVER_MAP }
      let(:driver_map_channel_params) do
        { action: 'TripAssigned',
          car_id: car.id,
          driver_id: driver.id,
          trip_id: trip.id }
      end

      before { allow(ActionCable.server).to receive(:broadcast) }

      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).with(trip_channel, trip_channel_params).once }
      it { expect(ActionCable.server).to receive(:broadcast).with(driver_map_channel, driver_map_channel_params).once }
    end
  end
end
