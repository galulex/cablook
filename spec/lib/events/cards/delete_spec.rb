describe Events::Cards::Delete do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:data) { { card_id: card.id, user_id: user.id } }
    let(:card) { create(:card, user_id: user.id) }
    let(:user) { create(:user) }

    it { is_expected.to change { Card.count }.by(-1) }

    context 'when payment is exists' do
      let!(:payment) { create(:payment, card_id: card.id, user_id: user.id, status: Constants::Payments::SUCCESS) }

      it { is_expected.to change { payment.reload.card_id }.to(nil) }

      context 'when multiple payments' do
        let!(:payment_2) { create(:payment, card_id: card.id, user_id: user.id, status: Constants::Payments::SUCCESS) }

        it { is_expected.to change { payment_2.reload.card_id }.to(nil) }
      end
    end

    context 'when card not found' do
      let(:card) { create(:card) }

      it { is_expected.not_to change { Card.count } }
    end

    context 'when pending payment' do
      let!(:trip) { create(:trip, user_id: user.id, status: Constants::Trip::FINISHED) }
      let!(:payment) { create(:payment, user_id: user.id, status: Constants::Payments::PENDING, trip: trip) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
