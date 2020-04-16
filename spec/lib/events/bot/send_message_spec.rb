
describe Events::Bot::SendMessage do
  describe '#run' do
    subject { -> { described_class.call(data) } }
    let(:default_data) { { chat_id: '1234', message: 'Hi' } }

    context 'when absent chat_id' do
      let(:data) { default_data.except(:chat_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when absent message' do
      let(:data) { default_data.except(:message) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end

