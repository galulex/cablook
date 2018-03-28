describe Repositories::Payment do
  describe '#by_trip' do
    let(:instance) { payment_repository.by_trip(trip.id) }
    let!(:payment) { Factory[:payment] }
    let(:trip) { Factory[:trip] }

    it { expect(instance).to be nil }

    context 'when payment is found' do
      let!(:payment) { Factory[:payment, trip_id: trip.id] }

      it { expect(instance.id).to eq(payment.id) }
    end
  end

  describe '#pending_by_user' do
    let(:instance) { payment_repository.pending_by_user(user.id) }
    let!(:payment) { Factory[:payment, user_id: user.id, status: Constants::Payments::HOLD] }
    let(:user) { Factory[:user] }

    it { expect(instance).to be_empty }

    context 'when payment is found' do
      let!(:payment) { Factory[:payment, status: Constants::Payments::PENDING, user_id: user.id] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#by_user' do
    let(:instance) { payment_repository.by_user(user.id) }
    let!(:payment) { Factory[:payment] }
    let(:user) { Factory[:user] }

    it { expect(instance).to be_empty }

    context 'when payment is found' do
      let!(:payment) { Factory[:payment, user_id: user.id] }

      it { expect(instance).not_to be_empty }
    end
  end

  describe '#nullify_card' do
    subject { -> { payment_repository.nullify_card(card.id) } }

    let!(:payment) { Factory[:payment, card_id: card.id] }
    let(:card) { Factory[:card] }

    it { is_expected.to change { payment_repository.by_id(payment.id).card_id }.from(card.id).to(nil) }
  end
end
