describe Events::Trips::Cancel do
  describe '.call' do
    let(:car) { create(:car, status: Constants::Car::DURING_TRIP) }
    let(:driver) { create(:driver, car_id: car.id) }
    let(:trip) { create(:trip, status: Constants::Trip::PENDING) }
    let(:data) { { trip_id: trip.id } }
    let(:card) { create(:card, user_id: trip.user.id) }

    subject { -> { described_class.call(data) } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: trip.user.id, card_id: card.id) }
    let!(:price) { Price.create }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }
    it { is_expected.to have_enqueued_job(Jobs::Notification) }
    it { is_expected.to have_enqueued_job(Jobs::DriversNotification).with(trip, 'clear') }

    context 'and payment status is changed' do
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }
    end

    context 'and have fake settle job' do
      let(:trip) { create(:trip, status: Constants::Trip::WAITING_CLIENT) }
      let(:data) { { trip_id: trip.id, by_driver: true } }

      it { is_expected.to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:fake], price.landing / 100) }
    end

    context 'and not have fake settle job when waiting for client' do
      it { is_expected.not_to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:fake], price.landing / 100) }
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).twice }
    end

    context 'when trip is on the way' do
      let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, status: Constants::Trip::ON_THE_WAY) }

      it { is_expected.to change { trip.car.reload.status }.to(Constants::Car::STATUS_CODES[Constants::Car::FREE]) }
    end

    context 'when driver have two trips and cancel first' do
      let(:first_trip) { create(:trip, car_id: car.id, driver_id: driver.id, status: Constants::Trip::WAITING_CLIENT) }
      let(:trip) { create(:trip, car_id: car.id, driver_id: driver.id, status: Constants::Trip::ON_THE_WAY) }
      let(:payment) { create(:payment, trip_id: first_trip.id, user_id: first_trip.user.id) }
      let(:data) { { trip_id: first_trip.id } }

      it { is_expected.not_to(change { trip.car.reload.status }) }
    end

    context 'when trip is on the way' do
      let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY) }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }
    end

    context 'when canceled by driver' do
      let(:data) { { trip_id: trip.id, by_driver: true } }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED_BY_DRIVER]) }
    end

    context 'when notification param' do
      let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }
      let(:data) { { trip_id: trip.id, notification: true } }

      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFICATION_CANCEL,
          data: {
            delivered: true
          }
        ).once
        subject.call
      end
    end
    context 'when trip not found' do
      let(:data) { { trip_id: 100_000 } }

      it { is_expected.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when trip is declined' do
      let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }

      it { is_expected.not_to(change { trip.reload.status }) }
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: trip.user_id) }
      let!(:bonus_trip) { create(:bonus_trip, trip_id: trip.id, status: :used, user_id: trip.user_id) }

      it { is_expected.to change { bonus_trip.reload.fresh? }.to be_truthy }
    end

    context 'when trip is finished' do
      let(:trip) { create(:trip, status: Constants::Trip::FINISHED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is already canceled' do
      let(:trip) { create(:trip, status: Constants::Trip::CANCELED) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip is driving' do
      let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when data is invalid' do
      let(:data) { {} }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when driving trip canceled by user' do
      let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when driving trip canceled by driver' do
      context 'and trip status is changed' do
        let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }
        let(:data) { { trip_id: trip.id, by_driver: true } }

        it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED_BY_DRIVER]) }
      end

      context 'and payment status is changed' do
        let(:trip) { create(:trip, status: Constants::Trip::ON_THE_WAY) }
        let(:data) { { trip_id: trip.id, by_driver: true } }

        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }
      end

      context 'and job deleted' do
        let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }
        let(:data) { { trip_id: trip.id, by_driver: true } }

        it { is_expected.not_to have_enqueued_job(Jobs::PaymentSettle).with(trip.id) }
      end

      context 'and payment by bonus' do
        let(:trip) { create(:trip, status: Constants::Trip::DRIVING) }
        let(:data) { { trip_id: trip.id, by_driver: true } }
        let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: trip.user_id) }
        let!(:bonus_trip) { create(:bonus_trip, trip_id: trip.id, status: :used, user_id: trip.user_id) }

        it { is_expected.to change { bonus_trip.reload.fresh? }.to be_truthy }
      end
    end

    context 'when payment system Fondy' do
      before { Settings.update!(payment_system: :fondy) }

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }
      it { is_expected.to have_enqueued_job(Jobs::Notification) }

      context 'and have fake taxi settle job' do
        let(:trip) { create(:trip, status: Constants::Trip::WAITING_CLIENT) }
        let(:data) { { trip_id: trip.id, by_driver: true } }

        it { is_expected.to have_enqueued_job(Jobs::PaymentSettle).with(trip.id, Constants::Payments::TYPES[:fake], price.landing / 100) }
      end

      context 'and canceled by user' do
        let(:trip) { create(:trip, status: Constants::Trip::PENDING) }
        let(:data) { { trip_id: trip.id, by_driver: false } }
        let(:reverse_params) { [trip.cost, trip.trip_payment.order_reference] }
        let(:reverse_stub) { double(Fondy::Reverse, call: { reverse_status: 'approved' }) }

        before do
          allow(Fondy::Reverse).to receive(:new).with(*reverse_params).and_return(reverse_stub)

          subject.call
        end

        it { (expect(Fondy::Reverse).to have_received(:new).with(*reverse_params).once) }
        it { (expect(trip.reload.status).to eq(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED])) }
      end
    end

    context 'when cash trip' do
      let!(:payment) { create(:trip_payment, trip_id: trip.id, user_id: trip.user.id, payment_method: Constants::Payments::METHOD_CASH) }

      context 'and not to starts refund money' do
        before do
          allow(Fondy::Reverse).to receive(:new).and_return(true)

          subject.call
        end

        it { (expect(Fondy::Reverse).to_not have_received(:new)) }
      end

      context 'and canceled by driver' do
        let(:data) { { trip_id: trip.id, by_driver: true } }

        it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED_BY_DRIVER]) }
        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }
      end

      context 'and canceled by user' do
        let(:data) { { trip_id: trip.id, by_driver: false } }

        it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::CANCELED]) }
        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::DECLINE) }
      end
    end
  end
end
