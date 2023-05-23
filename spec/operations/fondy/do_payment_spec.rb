describe Operations::Fondy::DoPayment do
  let(:instance) { described_class.new(trip.id, payment_type, amount) }
  let(:success) { Constants::Payments::FONDY_SUCCESS }
  let(:payout_response) { { response_status: success, payout: 'Driver payout', status: true } }
  let(:capture_response) { { response_status: success, status: true } }
  let(:recurring_response) { { response_status: success, status: true }  }

  before do
    allow_any_instance_of(Operations::Fondy::DriverPayOut).to receive(:call).and_return(payout_response)
    allow_any_instance_of(Fondy::Capture).to receive(:call).and_return(capture_response)
    allow_any_instance_of(Fondy::Recurring).to receive(:call).and_return(recurring_response)
  end

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, type: "Payments::#{payment_type}") }
    let!(:payment_type) { 'Trip' }
    let(:amount) { payment.amount }
    let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    let(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
    let(:cashback) { 15 }
    let(:user) { create(:user, cashback: cashback) }

    context 'when payment have success status' do
      let(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, status: Constants::Payments::SUCCESS) }

      it { is_expected.not_to change { payment.reload.order_reference } }
    end

    context 'when payment_type is Trip' do
      context 'and payment status is Bonus' do
        let(:payment) { create(:payment, trip_id: trip.id, user_id: user.id, card_id: card.id, status: Constants::Payments::BONUS) }

        it { is_expected.not_to change { Payments::Trip.count } }
        it { is_expected.not_to change { payment.reload.status } }
        it { is_expected.not_to change { payment.reload.response } }
        it { is_expected.not_to change { trip.reload.total } }
      end

      it { is_expected.to change { trip.reload.total }.from(0).to(trip.payments.sum(:amount)) }

      context 'and Fondy status is ok' do
        it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
        it { is_expected.to change { payment.reload.response }.from(nil) }
        it { is_expected.to_not change { user.reload.cashback } }

        context 'when cashback enabled' do
          before { Settings.get.update(cashback: true) }
          
          it { is_expected.to change { user.reload.cashback }.from(cashback).to(cashback + (trip.cost * 0.05 * 100).to_i) }
        end

        context 'capture amount' do
          after { subject.call }

          it { expect_any_instance_of(Fondy::Capture).to receive(:call).once }
        end

        context 'driver payout' do
          after { subject.call }

          it { expect_any_instance_of(Operations::Fondy::DriverPayOut).to receive(:call).once }
        end
      end

      context 'and Fondy status is not ok' do
        let(:capture_response) { { response_status: 'failed' } }

        it { is_expected.not_to change { payment.reload.status } }
        it { is_expected.to change { payment.reload.response } }
        it { is_expected.not_to change { Payments::PayOut.count } }
      end

      context 'and user have frozen bonuses' do
        let(:frozen_bonus) { create(:bonus_trip, user_id: user.id, status: :iced) }

        it { is_expected.to_not change { frozen_bonus.reload.fresh? } }

        context 'when bonuses enabled' do
          before { Settings.get.update(bonuses: true) }

          it { is_expected.to change { frozen_bonus.reload.fresh? }.to be_truthy }
        end

        context 'and user have not finished trips' do
          let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::PENDING) }

          it { is_expected.not_to change { frozen_bonus.reload.status } }
        end

        context 'and Fondy status is not ok' do
          let(:recurring_response) { { response_status: 'failed' } }

          it { is_expected.not_to change { frozen_bonus.reload.status } }
        end
      end
    end

    context 'when payment_type is Tip' do
      let!(:payment_type) { 'Tip' }

      context 'and Fondy status is ok' do
        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'driver payout' do
        after { subject.call }

        it { expect_any_instance_of(Operations::Fondy::DriverPayOut).to receive(:call).once }
      end

      context 'and Fondy status is not ok' do
        let(:recurring_response) { { response_status: 'failed' } }

        before { subject.call }

        it { expect(Payments::Tip.last.status).to eq(Constants::Payments::PENDING) }
      end
    end

    context 'when payment_type is Idle' do
      let!(:payment_type) { 'Idle' }

      context 'and Fondy status is ok' do
        let(:idle_payment) { Payments::Idle.last }

        before { subject.call }

        it { expect(Payments::Idle.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and Fondy status is not ok' do
        let(:recurring_response) { { response_status: 'failed' } }

        before { subject.call }

        it { expect(Payments::Idle.last.status).to eq(Constants::Payments::PENDING) }
      end
    end

    context 'when payment_type is FakeTaxi' do
      let!(:payment_type) { 'FakeTaxi' }

      context 'and Fondy status is ok' do
        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::SUCCESS) }
      end

      context 'and Fondy status is not ok' do
        let(:capture_response) { { response_status: 'failed' } }

        before { subject.call }

        it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::PENDING) }
      end
    end
  end
end
