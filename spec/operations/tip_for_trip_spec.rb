describe Operations::TipForTrip do
  let(:instance) { described_class.new(trip.id, amount) }
  let(:trip) { create(:trip, user_id: user.id) }
  let(:user) { create(:user) }
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
  let(:amount) { 10 }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { create(:payment, trip_id: trip.id, card_id: card.id, user_id: user.id) }

    it do
      expect(Wayforpay::Payments).to receive(:hold).once
      subject.call
    end

    it { is_expected.to change { Tip.count }.by(+1) }

    context 'when payment without card_id' do
      let!(:payment) { create(:payment, trip_id: trip.id, card_id: card.id, user_id: user.id) }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        subject.call
      end
    end
  end
end
