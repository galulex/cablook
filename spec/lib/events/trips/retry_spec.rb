describe Events::Trips::Retry do
  describe '.call' do
    let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }
    let(:user) { create(:user) }
    let!(:card) { create(:card, user_id: user.id) }
    let!(:trip_payment) { create(:trip_payment, trip: trip, user: user, card: card, status: Constants::Payments::DECLINE) }

    let(:data) { { trip_id: trip.id, user_id: user.id } }

    subject { -> { described_class.call(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]) }
    it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::PENDING) }
    it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(trip.id) }
    it do
      expect(ActionCable.server).not_to receive(:broadcast).with(
        "#{Constants::Channels::TRIP}_#{trip.id}",
        action: Constants::BroadcastActions::NOTIFICATION_RETRY
      )
    end

    context 'when payment system Fondy' do
      let!(:card) { create(:card, user_id: user.id, payment_system: :fondy) }

      before do
        Settings.update(payment_system: :fondy)
        allow_any_instance_of(described_class).to receive(:hold_success?).and_return(true)
      end

      it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::PENDING]) }
      it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::PENDING) }
      it { expect_any_instance_of(Fondy::Recurring).to_not receive(:call) }
      it { is_expected.to have_enqueued_job(Jobs::DeclineTrip).with(trip.id) }
      it { is_expected.to have_enqueued_job(Jobs::RefundHoldedAmount).with(trip.id, trip.cost, trip_payment.order_reference) }
      it do
        expect(ActionCable.server).not_to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFICATION_RETRY
        )
      end

      context 'without holded money' do
        let(:fresh_order_reference) { 'cablook_test_1_payments_trip_biUwx3' }
        let(:recurring_stub) { double(Fondy::Recurring, call: { order_status: 'approved', response_status: 'success', status: true }) }
        let(:status_stub) { double(Fondy::Recurring, call: { order_status: 'declined', response_status: 'failed', status: false }) }
        let(:recurring_params) { [user, trip.cost, card.token, fresh_order_reference, true] }

        before do
          allow_any_instance_of(described_class).to receive(:hold_success?).and_call_original
          allow_any_instance_of(described_class).to receive(:fresh_order_reference).and_return(fresh_order_reference)
          allow(Fondy::Recurring).to receive(:new).and_return(recurring_stub)
          allow(Fondy::PaymentStatus).to receive(:new).and_return(status_stub)
          described_class.call(data)
        end

        it { (expect(Fondy::Recurring).to have_received(:new).with(*recurring_params).once) }
      end
    end

    context 'when notification param present' do
      let(:trip) { create(:trip, status: Constants::Trip::DECLINED) }
      let(:data) { { trip_id: trip.id, user_id: user.id, notification: true } }

      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFICATION_RETRY,
          data: {
            delivered: true
          }
        ).once
        subject.call
      end
    end

    context 'and broadcast to channel' do
      after { subject.call }

      it { expect(ActionCable.server).to receive(:broadcast).once }
    end

    context 'when payment by bonus' do
      let!(:bonus_trip) { create(:bonus_trip, trip: trip, user_id: user.id, status: :fresh) }

      after { subject.call }

      it { is_expected.to change { bonus_trip.reload.used? }.to be_truthy }
      it { is_expected.to change { trip_payment.reload.status }.to(Constants::Payments::BONUS) }
    end

    context 'when user has no cards' do
      let(:trip_1) { create(:trip, status: Constants::Trip::DECLINED) }
      let(:user_1) { create(:user) }
      let!(:trip_payment) { create(:trip_payment, trip: trip_1, user: user_1, card: card, status: Constants::Payments::PENDING) }

      let(:data) { { trip_id: trip_1.id, user_id: user_1.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
