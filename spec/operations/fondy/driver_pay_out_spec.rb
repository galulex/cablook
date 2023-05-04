describe Operations::Fondy::DriverPayOut do
  let(:instance) { described_class.new(payment.id) }
  let!(:charge_response) { { response_status: Constants::Payments::FONDY_SUCCESS } }
  let!(:user) { create(:user) }
  let!(:card) { create(:card, user_id: user.id, payment_system: :fondy) }
  let!(:trip) { create(:trip, user_id: user.id, driver_id: driver.id) }
  let!(:driver) { create(:driver) }

  before { allow_any_instance_of(described_class).to receive(:payout_response).and_return(charge_response) }

  describe '#call' do
    subject { -> { instance.call } }

    let(:payment) { create(:trip_payment, user_id: user.id, trip_id: trip.id, card_id: card.id) }
    let(:payout_payment) { Payments::PayOut.find_by!(trip_id: trip.id)}

    context 'when payout status is ok' do
      before { subject.call }

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { expect(payout_payment.reload.status).to eq(Constants::Payments::SUCCESS) }
    end

    context 'when payout status is not ok' do
      let!(:charge_response) { { response_status: 'failed' } }

      before { subject.call }

      it { is_expected.to change { Payments::PayOut.count }.by(+1) }
      it { expect(payout_payment.reload.status).to eq(Constants::Payments::PENDING) }
    end
  end
end
