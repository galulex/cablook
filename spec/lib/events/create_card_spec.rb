describe Events::CreateCard do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      JSON.parse(File.read('spec/fixtures/card_callback.json'))
          .symbolize_keys
          .merge(user_id: user.id)
    end
    let(:user) { Factory[:user] }

    context 'when card is created successfully' do
      it { is_expected.to change { cards_repository.cards.count }.by(+1) }
    end

    context 'when user with data number not found' do
      let(:data) { super().merge(user_id: 9999) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when token is invalid' do
      let(:data) { super().merge(recToken: nil) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }

      context 'when token already exist' do
        let(:card) { Factory[:card, user_id: user.id] }
        let(:data) { super().merge(recToken: card.token) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end
    end
  end
end
