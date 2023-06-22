describe Operations::Fondy::RetryPayment do
  let(:instance) { described_class.new(payment.id, card.id) }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
  let(:success) { Constants::Payments::FONDY_SUCCESS }
  let(:payout_double) { double(Fondy::ChargeCard, call: { response_status: success, payout: 'Driver payout', status: true }) }
  let(:status_response) { { order_status: 'not approved', status: false } }
  let(:recurring_response) { { response_status: success, status: true } }
  let(:correct_payout_amount) { payment.amount - (payment.amount * Operations::Fondy::DriverPayOut::FONDY_FEE) }

  before do
    Settings.update!(payment_system: :fondy)
    allow_any_instance_of(Fondy::PaymentStatus).to receive(:call).and_return(status_response)
    allow_any_instance_of(Fondy::Recurring).to receive(:call).and_return(recurring_response)
    allow(Fondy::ChargeCard).to receive(:new).and_return(payout_double)
  end

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:trip_payment, user_id: user.id, status: Constants::Payments::PENDING) }

    context 'retry payment successfully with check status and driver payout' do
      after { subject.call }

      it { expect_any_instance_of(Fondy::Recurring).to receive(:call).once }
      it { expect_any_instance_of(Operations::Fondy::DriverPayOut).to receive(:call).once }
      it { expect_any_instance_of(Fondy::PaymentStatus).to receive(:call).once }
      it { expect(Fondy::ChargeCard).to receive(:new).with(payment, correct_payout_amount) }
    end

    it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
    it { is_expected.to change { payment.reload.response }.to(JSON.parse(recurring_response.to_json)) }
    it { is_expected.to change { user.reload.cashback } }

    context 'when cashback disabled' do
      before { Settings.disable(:cashback) }

      it { is_expected.to_not change { user.reload.cashback } }
    end

    context 'when Fondy already has successfull payment status' do
      let!(:status_response) { { order_status: Constants::Payments::FONDY_APPROVED, status: true } }

      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(status_response.to_json)) }
    end

    context 'when cashback enabled' do
      it { is_expected.to change { user.reload.cashback }.to(user.cashback + payment.amount * 100 * 0.05) }
    end

    context 'when payment type is not trip' do
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, type: 'Payments::Tip') }

      it { is_expected.not_to change { user.reload.cashback } }
      it { expect(Fondy::ChargeCard).to_not receive(:new) }
    end

    context 'when Fondy recurring response failed' do
      let(:recurring_response) { { response_status: 'failed' } }

      it { is_expected.not_to change { payment.reload.status } }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(recurring_response.to_json)) }
    end
  end
end
