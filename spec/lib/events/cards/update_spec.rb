describe Events::Cards::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      JSON.parse(File.read('spec/fixtures/second_card_callback.json'))
          .symbolize_keys
    end

    let(:card) { create(:card, token: 'testOrderReference') }

    context 'when recToken empty' do
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
  end
end