describe Events::CreateCard do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) { JSON.parse(File.read('spec/fixtures/card_callback.json')).symbolize_keys }

    context 'when card is created successfully' do
      before { Factory[:user, phone_number: "+#{data[:phone]}"] }

      it { is_expected.to change { cards_repository.cards.count }.by(+1) }
    end

    context 'when user with data number not found' do
      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when token is invalid' do
      let(:data) { super().merge(recToken: nil) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }

      context 'when token already exist' do
        let(:card) { Factory[:card] }
        let(:data) { super().merge(recToken: card.token) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end
    end

    context 'when transaction status is invalid' do
      let(:data) { super().merge(transactionStatus: 'test') }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
