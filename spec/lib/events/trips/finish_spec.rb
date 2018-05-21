describe Events::Trips::Finish do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { Factory[:trip, status: Constants::Trip::PENDING, car_id: car.id, driver_id: driver.id] }
    let(:driver) { Factory[:driver] }
    let(:car) { Factory[:car, status: Constants::Car::OFFLINE] }

    let(:data) { { trip_id: trip.id } }

    it { is_expected.to change { trip_repository.by_id(trip.id).status }.to(Constants::Trip::FINISHED) }
    it { is_expected.to change { car_repository.by_id(car.id).status }.to(Constants::Car::FREE) }
    it { is_expected.to have_enqueued_job(Jobs::PaymentSettle) }

    context 'and broadcast to driver map channel' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::TRIP_FINISH_ACTION,
          body: { action: Constants::BroadcastActions::TRIP_FINISHED }
        ).once
        subject.call
      end
    end

    context 'when driver has second trip' do
      let!(:next_trip) { Factory[:trip, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id] }
      let(:car) { Factory[:car, status: Constants::Car::DURING_IN_TRIP] }

      it 'keeps busy car status' do
        expect(car_repository.by_id(car.id).status).to eql(Constants::Car::DURING_IN_TRIP)
      end
    end
  end
end
