describe Operations::Wayforpay::Hold do
  let(:instance) { described_class.new(trip_id: trip.id, card_id: card.id) }
  let(:trip) { Factory[:trip, user_id: user.id] }
  let(:card) { Factory[:card, user_id: user.id] }
  let(:user) { Factory[:user] }
  let(:wayforpay_body) { { reasonCode: 1100 }.to_json }

  before { allow(Wayforpay::Payments).to receive(:hold) { OpenStruct.new(body: wayforpay_body) } }

  describe '#call' do
    subject { -> { instance.call } }

    context 'and payment is created' do
      it { is_expected.to change { payment_repository.payments.count }.by(+1) }

      it { is_expected.not_to have_enqueued_job(Jobs::Sms) }
    end

    context 'and broadcast to channel with status success' do
      after { subject.call }

      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::PAYMENT_RESPONSE,
          payment_status: Constants::Payments::HOLD
        )
      end
    end

    context 'when status is ok' do
      before { subject.call }

      it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::HOLD) }
    end

    context 'when smth went wrong' do
      let(:wayforpay_body) { { reasonCode: '1111' }.to_json }

      it { is_expected.to have_enqueued_job(Jobs::Sms) }

      context 'and the status of payment is pending' do
        before { subject.call }

        it { expect(payment_repository.payments.to_a.last.status).to eq(Constants::Payments::PENDING) }
      end

      context 'and broadcast to channel with status failed' do
        after { subject.call }

        it do
          expect(ActionCable.server).to receive(:broadcast).with(
            "#{Constants::Channels::TRIP}_#{trip.id}",
            action: Constants::BroadcastActions::PAYMENT_RESPONSE,
            payment_status: Constants::Payments::PENDING
          )
        end
      end
    end
  end
end
