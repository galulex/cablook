describe Operations::Wayforpay::IdleSettle do
  let(:instanse) { described_class.new(trip.id, idle) }
  let(:user) { create(:user) }
  let(:trip) { create(:trip, user_id: user.id) }
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
  let(:idle) { 12.minutes.to_i }
  let!(:price) { Price.create }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instanse.call } }

    let!(:payment) { create(:payment, trip_id: trip.id, card_id: card.id, user_id: user.id) }

    it { is_expected.to change { Payments::Idle.count }.by(+1) }

    context 'and total is changed' do
      let(:trip) { create(:trip, user_id: user.id, total: total) }
      let(:payment) { create(:payment, user_id: user.id, trip_id: trip.id, card_id: card.id, amount: total) }
      let(:total) { 40 }

      it { is_expected.to change { trip.reload.total }.from(total).to(total + idle / 60 * price.idle_price) }
    end

    context 'and wayfropay responce is ok' do
      let(:idle_payment) { Payments::Idle.last }

      before { subject.call }

      it { expect(idle_payment.status).to eq(Constants::Payments::SUCCESS) }
      it { expect(idle_payment.card_id).to eq(card.id) }
      it { expect(idle_payment.trip_id).to eq(trip.id) }
      it { expect(idle_payment.user_id).to eq(user.id) }
      it { expect(idle_payment.amount).to eq(idle / 60 * price.idle_price) }
      it { expect(idle_payment.order_reference).to include("cablook_#{Rails.env}_#{trip.id}_idle_") }
    end

    context 'when something went wrong' do
      let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

      before { subject.call }

      it { expect(Payment.last.status).not_to eq('1234') }
    end
  end
end
