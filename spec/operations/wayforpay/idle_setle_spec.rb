describe Operations::Wayforpay::IdleSettle do
  let(:instanse) { described_class.new(trip.id, idle)}
  let(:card) { create(:card, user_id: user.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    let!(:payment) { create(:payment, trip_id: trip.id, user_id: user.id) }
    let(:user) { create(:user) }

    context 'when idle send with status ok' do
      it { is_expected.to change { payment.reload.status }.to(Constants::Payments::SUCCESS) }
    end

    context 'when smth went wrong from wayforpay' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      it { is_expected.not_to change { trip.reload.comment } }
      it { is_expected.to change { payment.reload.response }.to(JSON.parse(wayforpay_body)) }
    end

    context 'when trip not found' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
    end
  end
end
