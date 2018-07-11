describe Operations::Wayforpay::IdleSettle do
    let(:instanse) { described_class.new(trip.id, idle) }
    let(:user) { create(:user) }
    let(:trip) { create(:trip, user_id: user.id) }
    let(:card) { create(:card, user_id: user.id) }
    let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }
    let(:idle) { 800 }
  
    before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }
  
    describe '#call' do
      subject { -> { instanse.call } }
  
      let!(:payment) { create(:payment, trip_id: trip.id, card_id: card.id, user_id: user.id) }
  
      it { is_expected.to change { Payments::Idle.count }.by(+1) }
  
      context 'and wayfropay responce is ok' do
        before { subject.call }
        
        let(:total){ trip.reload.total }

        it { expect(Payments::Idle.last.status).to eq(Constants::Payments::SUCCESS) }
        it { is_expected.to change { trip.reload.total }.to(total + idle / 60 * Constants::Payments::IDLE_PRICE) }
      end
  
      context 'when something went wrong' do
        let(:wayforpay_body) { { reasonCode: '1234' }.to_json }
  
        before { subject.call }
  
        it { expect(Payment.last.status).not_to eq('1234') }
      end
    end
  end