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
      
    it { is_expected.to change { Payments::Tip.count }.by(+1) }
    
    context 'and wayfropay responce is ok' do
      before { subject.call }
      it { expect(Payment.last.status).to eq(Constants::Payments::SUCCESS) }
    end
    
    context 'when something went wrong' do
      let(:wayforpay_body) { { reasonCode: '1234' }.to_json }
      
      before { subject.call }
      it { expect(Payment.last.status).not_to eq('1234') }
    
    end

    context 'when payment without card_id' do
      let!(:payment) { create(:payment, trip_id: trip.id, card_id: card.id, user_id: user.id) }

      it do
        expect(Wayforpay::Payments).to receive(:hold).once
        subject.call
      end 
    end
  end
end
