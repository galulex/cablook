describe Operations::Wayforpay::FakeSettle do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let(:trip) { create(:trip, user_id: user.id) }
    let(:user) { create(:user) }
    let(:card) { create(:card, user_id: user.id) }
    let!(:payment) { create(:payment, card_id: card.id, user_id: user.id, trip_id: trip.id) }

    it { is_expected.to change { Payments::FakeTaxi.count }.by(+1) }

    context 'and trip total is changed' do
      it { is_expected.to change { trip.reload.total }.from(trip.total).to(trip.total + Price.last.landing/100) }
    end

    context 'when wayforpay response is ok' do
      before { subject.call }

      it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::SUCCESS) }
    end

    context 'when something want wrong' do
      let(:wayforpay_body) { { reasonCode: '1234' }.to_json }

      before { subject.call }

      it { expect(Payments::FakeTaxi.last.status).to eq(Constants::Payments::PENDING) }

      context 'and trip total not changed' do
        it { is_expected.not_to change { trip.reload.total } }
      end
    end
  end
end
