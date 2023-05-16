describe Events::Trips::Finish do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:trip) { create(:trip, status: Constants::Trip::PENDING, car_id: car.id, driver_id: driver.id, user_id: user.id) }
    let(:user) { create(:user) }
    let(:driver) { create(:driver) }
    let(:car) { create(:car, status: Constants::Car::OFFLINE) }

    let(:data) { { trip_id: trip.id, idle: 0 } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]) }
    it { is_expected.to change { car.reload.status }.to('free') }

    context 'when trip has bonus trip' do
      let!(:bonus_trip) { create(:bonus_trip, user: user, trip: trip, type: Constants::BonusTrip::GIFT) }

      it { is_expected.not_to have_enqueued_job(Jobs::PaymentSettle) }

      context 'with cashback type' do
        let!(:bonus_trip) { create(:bonus_trip, user: user, trip: trip, type: Constants::BonusTrip::CASHBACK) }

        it { is_expected.to_not change { user.reload.cashback } }

        context 'when cashback enabled' do
          before {Settings.get.update(cashback: true)}

          it { is_expected.to change { user.reload.cashback }.to(user.cashback - trip.cost * 100) }
        end
      end
    end

    context 'when trip is already finished' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when idle is bigger than 10' do
      let(:data) { { trip_id: trip.id, idle: idle} }
      let(:price) { Price.create }
      let(:idle) { 800 }
      let(:card) { create(:card, user_id: user.id) }
      let!(:trip_payment) { create(:trip_payment, user_id: user.id, card_id: card.id, trip_id: trip.id) }

      it { is_expected.to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:idle], idle / 60 * price.idle_price) }
    end

    context 'when idle is lower than 10' do
      let(:data) { { trip_id: trip.id, idle: 8} }

      it { is_expected.not_to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:idle],  8) }
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

    context 'when payment system Fondy' do
      before { Settings.get.update!(payment_system: :fondy) }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]) }
      it { is_expected.to change { car.reload.status }.to('free') }
      it { is_expected.to have_enqueued_job(Jobs::PaymentSettle) }
    end
  end
end
