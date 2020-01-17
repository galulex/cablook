describe Events::Trips::Finish do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { create(:trip, status: Constants::Trip::PENDING, car_id: car.id, driver_id: driver.id) }
    let(:driver) { create(:driver) }
    let(:car) { create(:car, status: Constants::Car::OFFLINE) }

    let(:data) { { trip_id: trip.id, idle: 0 } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]) }
    it { is_expected.to change { car.reload.status }.to('free') }

    context 'when trip is already canceled' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when idle is bigger than 10' do
      let(:data) { { trip_id: trip.id, idle: 800} }

      it { is_expected.to have_enqueued_job(Jobs::PaymentIdleSettle).with(trip.id, 800) }
    end

    context 'when idle is lower than 10' do
      let(:data) { { trip_id: trip.id, idle: 8} }

      it { is_expected.not_to have_enqueued_job(Jobs::PaymentIdleSettle).with(trip.id, 8) }
    end
    
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
      let!(:next_trip) { create(:trip, status: Constants::Trip::ON_THE_WAY, car_id: car.id, driver_id: driver.id) }
      let(:car) { create(:car, status: Constants::Car::DURING_TRIP) }

      it 'keeps busy car status' do
        expect(car.reload.status).to eq('during_trip')
      end
    end
  end
end
