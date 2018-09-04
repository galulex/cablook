describe Operations::RetryAllPendingPayments do
  let(:instance) { described_class.new() }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id)}
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
  let(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]) }
 
  before { allow_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call).once }

  describe '#call' do
    subject { -> { instance.call } }

    before do
      create(:payment, user_id: user.id, card_id: card.id, status: Constants::Payments::BONUS)
      create(:payment, user_id: user.id, card_id: card.id, trip_id: trip.id, status: Constants::Payments::PENDING)
    end

    it do
      expect_any_instance_of(Operations::Wayforpay::RetryPayment).to receive(:call).once
      subject.call
    end
  end
end
