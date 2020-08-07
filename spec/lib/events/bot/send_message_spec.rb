
describe Events::Bot::SendMessage do
  describe '#run' do
    subject { -> { described_class.call(data) } }
    let(:default_data) { { chat_id: '1234', message: 'Hi', location: [32.073095, 49.418461] } }

    context 'when absent chat_id' do
      let(:data) { default_data.except(:chat_id) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when absent message' do
      let(:data) { default_data.except(:message) }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when location' do
      context 'empty' do
        let(:data) { default_data.except(:location) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end

      context 'not float' do
        let(:data) { default_data.merge(location: [22, 33]) }

        it { is_expected.to raise_error(Events::InvalidParamsError) }
      end
    end

    context 'and rerun when bot fails' do
      let(:data) { default_data }

      before do
        allow(Telegram).to receive('bot').and_raise(Telegram::Bot::Error)
        expect(Jobs::TelegramSendMessage).to receive_message_chain(:set, :perform_later)
      end

      it { subject.call }
    end
  end
end
