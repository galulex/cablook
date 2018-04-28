describe Events::Cards::Delete do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:data) { { card_id: card.id, user_id: user.id } }
    let(:card) { Factory[:card, user_id: user.id] }
    let(:user) { Factory[:user] }

    it { is_expected.to change { card_repository.cards.count }.by(-1) }

    context 'when payment is exists' do
      let!(:payment) { Factory[:payment, card_id: card.id] }

      it { is_expected.to change { payment_repository.by_id(payment.id).card_id }.to(nil) }

      context 'when multiple payments' do
        let!(:payment_2) { Factory[:payment, card_id: card.id] }

        it { is_expected.to change { payment_repository.by_id(payment_2.id).card_id }.to(nil) }
      end
    end

    context 'when card not found' do
      let(:card) { Factory[:card] }

      it { is_expected.not_to change { card_repository.cards.count } }
    end

    context 'when pending payment' do
      let!(:payment) { Factory[:payment, user_id: user.id, status: Constants::Payments::PENDING] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when hold payment' do
      before { Factory[:payment, user_id: user.id, status: Constants::Payments::HOLD] }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
