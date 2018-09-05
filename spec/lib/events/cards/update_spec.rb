describe Events::Cards::Update do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:data) do
      JSON.parse(File.read('spec/fixtures/second_card_callback.json'))
          .symbolize_keys
          .merge(recToken: 'testToken')
    end
    let(:card) { create(:card, token: '88005553535aaa') }

    context 'when card is updated successfully' do
      it { is_expected.to change { card.reload.token }.to(data[:recToken]) }
    end

    context 'when recToken is empty' do
      let(:data) { super().merge(recToken: nil) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end