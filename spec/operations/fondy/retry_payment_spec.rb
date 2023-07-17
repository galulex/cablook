describe Operations::Fondy::RetryPayment do
  let(:instance) { described_class.new(payment.id, card.id) }
  let(:user) { create(:user) }
  let(:driver) { create(:driver) }
  let(:trip) { create(:trip, driver: driver) }
  let(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
  let(:success) { Constants::Payments::FONDY_SUCCESS }
  let(:status_response) { { order_status: 'not approved', status: false } }
  let(:recurring_response) { { response_status: success, status: true } }

  before do
    Settings.update!(payment_system: :fondy)
    allow_any_instance_of(Fondy::PaymentStatus).to receive(:call).and_return(status_response)
    allow_any_instance_of(Fondy::Recurring).to receive(:call).and_return(recurring_response)
  end

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:trip_payment, user_id: user.id, trip_id: trip.id, status: Constants::Payments::PENDING) }

    context 'retry payment successfully with check status and driver balance updates' do
      after { subject.call }

      it { expect_any_instance_of(Fondy::Recurring).to receive(:call).once }
      it { expect_any_instance_of(Fondy::PaymentStatus).to receive(:call).once }
    end

    it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
    it { is_expected.to change { payment.reload.response }.to(JSON.parse(recurring_response.to_json)) }
    it { is_expected.to change { user.reload.cashback } }
    it { is_expected.to change { driver.reload.balance }.by(payment.amount) }

    context 'when cashback disabled' do
      before { Settings.disable(:cashback) }

      it { is_expected.to_not change { user.reload.cashback } }
    end

    context 'when Fondy already has successfull payment status' do
      let!(:status_response) { { order_status: Constants::Payments::FONDY_APPROVED, status: true } }

      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(status_response.to_json)) }
      it { is_expected.not_to change { driver.reload.balance } }
    end

    context 'when cashback enabled' do
      it { is_expected.to change { user.reload.cashback }.to(user.cashback + payment.amount * 100 * 0.05) }
    end

    context 'when payment type is not trip' do
      let!(:payment) { create(:payment, user_id: user.id, trip_id: trip.id, status: Constants::Payments::PENDING, type: 'Payments::Tip') }

      it { is_expected.not_to change { user.reload.cashback } }
      it { is_expected.to change { driver.reload.balance }.by(payment.amount) }
    end

    context 'when Fondy recurring response failed' do
      let(:recurring_response) { { response_status: 'failed' } }

      it { is_expected.not_to change { payment.reload.status } }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(recurring_response.to_json)) }
      it { is_expected.not_to change { driver.reload.balance } }
    end
  end
end
