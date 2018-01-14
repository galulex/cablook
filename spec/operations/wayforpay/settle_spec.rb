describe Operations::Wayforpay::Settle do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: '1100' }.to_json }

  before { allow(Wayforpay::Payments).to receive(:settle) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { Factory[:trip, user_id: user.id] }
    let!(:payment) { Factory[:payment, trip_id: trip.id] }
    let(:user) { Factory[:user] }


    context 'when status is ok' do
      before { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::SUCCESS) }
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      before { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::PENDING) }
    end
  end
end
