describe Events::DeleteCard do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let!(:data) { { card_id: card.id, user_id: user.id } }
    let(:card) { Factory[:card, user_id: user.id] }
    let(:user) { Factory[:user] }

    it { is_expected.to change { cards_repository.cards.count }.by(-1) }

    context 'when card not found' do
      let(:card) { Factory[:card] }

      it { is_expected.not_to change { cards_repository.cards.count } }
    end
  end
end
