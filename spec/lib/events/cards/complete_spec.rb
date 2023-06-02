describe Events::Cards::Complete do
  describe '.call' do
    subject { -> { described_class.call(params: data) } }

    let(:data) { JSON.parse(File.read('spec/fixtures/second_card_callback.json')).symbolize_keys }

    let(:card) { create(:card, token: 'testOrderReference') }

    context 'when orderReference empty' do
      let(:data) { super().merge(orderReference: '') }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when card updated successfully' do
      let(:data) { super().merge(recToken: 'testToken') }

      it { is_expected.to change { card.reload.token }.to(data[:recToken]) }
    end

    context 'when recToken already exsist' do
      let!(:card) { create(:card, token: 'testToken') }
      let(:data) { super().merge(recToken: 'testToken') }

      it { is_expected.not_to change {} }
    end

    context 'when card transactionStatus: Declined' do
      let(:data) { super().merge(transactionStatus: 'Declined') }

      it { is_expected.not_to change {} }
    end

    context 'when payment system Fondy' do
      let(:data) { JSON.parse(File.read('spec/fixtures/fondy/create_callback.json')).symbolize_keys }
      let!(:user) { create(:user, id: 1) }

      before { Settings.update!(payment_system: :fondy) }

      it { is_expected.to change { Card.count }.by(1) }
    end
  end
end