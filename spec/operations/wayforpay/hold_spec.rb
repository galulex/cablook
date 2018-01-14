describe Operations::Wayforpay::Hold do
  let(:instance) { described_class.new(trip_id: trip.id, card_id: card.id) }

  describe '#call' do
    subject { -> { instance.call } }

    let(:trip) { Factory[:trip, user_id: user.id] }
    let(:card) { Factory[:card, user_id: user.id] }
    let(:user) { Factory[:user] }


    context 'and payment is created' do
      it { is_expected.to change { payment_repository.payments.count }.by(+1) }
    end

    context 'when status is ok' do
      after { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::HOLD) }
    end

    context 'when smth went wrong' do
      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::PENDING) }
    end
  end
end
