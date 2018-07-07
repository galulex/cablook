describe TripChannel do
  let(:channel) { described_class.new(connection, nil, trip_id: trip.id, idle: idle) }
  let(:connection) { TestConnection.new }
  let!(:trip) { create(:trip_with_driver) }
  let!(:idle){ 5 }

  context '#start_trip' do
    let(:data) do
      {
        'action' => 'start_trip',
        'body' => {
          'estimated_end_time' => Time.now + 10.minutes
        }.to_json
      }
    end

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::DRIVING]) }
    it { is_expected.to change { trip.reload.started_at }.from(nil) }
  end

  context '#finish_trip' do
    let(:data) { { 'action' => 'finish_trip' } }

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::FINISHED]) }
    it { is_expected.to change { trip.reload.finished_at }.from(nil) }
  end

  context '#waiting_client' do
    let(:data) { { 'action' => 'waiting_client' } }

    subject { -> { channel.perform_action(data) } }

    it { is_expected.to change { trip.reload.status }.to(Constants::Trip::STATUS_CODES[Constants::Trip::WAITING_CLIENT]) }
    it { is_expected.to change { trip.reload.arrived_at }.from(nil) }
  end
end
