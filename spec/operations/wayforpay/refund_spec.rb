describe Operations::Wayforpay::Refund do
  let(:instance) { described_class.new(payment.id) }
  let(:wayforpay_body) { { reasonCode: 1100 }.to_json }
  let!(:price) { Price.create }

  before { allow(Wayforpay::Payments).to receive(:refund) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    let!(:trip) { create(:trip, user_id: user.id) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when status is ok' do
      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when payment status is pending' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::PENDING, user_id: trip.user_id) }

      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::REFUND) }
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::DECLINE, user_id: trip.user_id, response: {}) }

      before { instance.call }

      it { expect(payment.reload.status).to eq(Constants::Payments::DECLINE) }
    end

    context 'when payment by bonus' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::BONUS, user_id: trip.user_id) }
      let!(:bonus_trip) { create(:bonus_trip, trip_id: trip.id, status: :used, user_id: trip.user_id) }

      before { instance.call }

      it { expect(bonus_trip.reload).to be_fresh }
    end

    context 'when fake taxi' do
      let!(:payment) { create(:payment, trip_id: trip.id, status: Constants::Payments::DECLINE, card_id: card.id, user_id: trip.user_id, response: {}) }
      let(:card) { create(:card) }
      let(:instance) { described_class.new(payment.id, fake: true) }

      before { allow(Wayforpay::Payments).to receive(:hold) }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        instance.call
      end
    end
  end
end
