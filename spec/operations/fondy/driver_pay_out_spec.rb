describe Operations::Fondy::DriverPayOut do
  let(:instance) { described_class.new(driver, payment.amount) }
  let!(:charge_response) { { response_status: Constants::Payments::FONDY_SUCCESS, status: true } }
  let!(:user) { create(:user) }
  let!(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
  let!(:trip) { create(:trip, user_id: user.id, driver_id: driver.id) }
  let!(:driver) { create(:driver, balance: 100) }

  describe '#call' do
    let(:payment) { create(:trip_payment, user_id: user.id, trip_id: trip.id, card_id: card.id) }
    let(:payout_payment) { Payments::PayOut.last }

    subject { -> { instance.call } }

    context 'when payout status is ok' do
      before { allow_any_instance_of(described_class).to receive(:payout_response).and_return(charge_response) }

      after { subject.call }

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
    end

    context 'when payout status is not ok' do
      let!(:charge_response) { { response_status: 'failed' } }

      before do
         allow_any_instance_of(described_class).to receive(:payout_response).and_return(charge_response)
         subject.call
      end

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { expect(payout_payment.reload.status).to eq(Constants::Payments::PENDING) }
    end

    context 'with correct payout amount' do
      let(:correct_payout_amount) { payment.amount - (payment.amount * Operations::Fondy::DriverPayOut::FONDY_FEE) }

      before do
        allow(Fondy::ChargeCard).to receive(:new).with(driver, correct_payout_amount).and_return(double(call: charge_response))
        subject.call
      end

      it { expect(payout_payment.amount).to eq(correct_payout_amount) }
      it { expect(Fondy::ChargeCard).to have_received(:new).with(driver, correct_payout_amount) }
    end
  end
end
