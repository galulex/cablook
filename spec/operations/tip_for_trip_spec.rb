describe Operations::TipForTrip do
  let(:instance) { described_class.new(trip.id, amount) }
  let(:trip) { Factory[:trip, user_id: user.id] }
  let(:user) { Factory[:user] }
  let(:card) { Factory[:card, user_id: user.id] }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
  let(:amount) { 10 }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:payment) { Factory[:payment, trip_id: trip.id, card_id: card.id, user_id: user.id] }

    it do
      expect(Wayforpay::Payments).to receive(:hold).once
      subject.call
    end

    it { is_expected.to change { ROM.env.relations.tips.count }.by(+1) }

    context 'when payment without card_id' do
      let!(:payment) { Factory[:payment, trip_id: trip.id, card_id: card.id, user_id: user.id] }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        subject.call
      end
    end
  end
end
