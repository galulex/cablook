describe Operations::Wayforpay::Settle do
  let(:instance) { described_class.new(trip.id) }
  let(:wayforpay_body) { { reasonCode: Constants::Payments::WAYFORPAY_SUCCESS }.to_json }

  before { allow(Wayforpay::Payments).to receive(:settle) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    let!(:trip) { Factory[:trip, user_id: user.id, status: Constants::Trip::FINISHED] }
    let!(:payment) { Factory[:payment, trip_id: trip.id] }
    let(:user) { Factory[:user] }


    context 'when status is ok' do
      it { is_expected.to change { payment_repository.by_id(payment.id).status }.to(Constants::Payments::SUCCESS) }

      context 'and give bonus trip for referrer' do
        let(:referrer) { Factory[:user] }
        let!(:bonus_trip) { Factory[:bonus_trip, user_id: referrer.id, friend_id: user.id] }

        it { is_expected.to change { bonus_trip_repository.by_id(bonus_trip.id).status }.to(Constants::BonusTrip::NEW) }
      end
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      before { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::PENDING) }
    end
  end
end
