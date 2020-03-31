describe Events::Drivers::Notify do
  describe '.call' do
    subject { -> { described_class.call(data) } }

    let(:user) { create(:user) }
    let(:message) { 'Some test message' }
    let(:trip) { create(:trip, user_id: user.id) }
    let(:data) { { trip_id: trip.id, message: message, message_type: 'reply' } }

    context 'when message_type is reply' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFY_DRIVER,
          data: {
            phone_number: trip.user.phone_number,
            message: message
          }.to_json
        ).once
        subject.call
      end
    end

    context 'when message_type is coming' do
      it do
        expect(ActionCable.server).to receive(:broadcast).with(
          "#{Constants::Channels::TRIP}_#{trip.id}",
          action: Constants::BroadcastActions::NOTIFY_DRIVER,
          data: {
            phone_number: trip.user.phone_number,
            message: message
          }.to_json
        ).once
        subject.call
      end
    end

    context 'when message_type is empty' do
      let(:data) { { trip_id: trip.id } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end

    context 'when trip_id is empty' do
      let(:data) { { message_type: 'coming' } }

      it { is_expected.to raise_error(Events::InvalidParamsError) }
    end
  end
end
