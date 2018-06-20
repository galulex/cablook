describe Operations::Wayforpay do
  describe '.hold' do
    let(:trip) { create(:trip, user_id: user.id) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    after { described_class.hold(trip.id, card.id) }

    it { expect(Operations::Wayforpay::Hold).to receive_message_chain(:new, :call) }
  end

  describe '.settle' do
    let(:trip) { create(:trip, user_id: user.id) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    after { described_class.settle(trip.id) }

    it { expect(Operations::Wayforpay::Settle).to receive_message_chain(:new, :call) }
  end

  describe '.refund' do
    let(:trip) { create(:trip, user_id: user.id) }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    after { described_class.refund(trip.id) }

    it { expect(Operations::Wayforpay::Refund).to receive_message_chain(:new, :call) }
  end
end
